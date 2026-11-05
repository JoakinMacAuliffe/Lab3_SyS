%% =========================================================================
% Laboratorio 3: Transformada de Fourier y Filtros - Seccion 5.1
% Analisis de Fourier: FFT y espectrograma de 5 senales
% Requiere: Signal Processing Toolbox (spectrogram, hann)
% Ejecutar desde la carpeta raiz del repositorio Lab3_SyS.
% Las figuras se exportan en PDF vectorial a la carpeta figuras/
% =========================================================================
clear; clc; close all;

outDir = 'figuras';
if ~exist(outDir, 'dir'); mkdir(outDir); end

%% ---------------------- Generacion de senales ---------------------------
Fs = 44100;                 % Frecuencia de muestreo [Hz]
t  = 0:1/Fs:1-1/Fs;         % 1 segundo -> N = 44100, resolucion 1 Hz

x1 = sin(2*pi*200*t);               % 1. Senoidal 200 Hz, amplitud 1
x2 = 10*sin(2*pi*500*t);            % 2. Senoidal 500 Hz, amplitud 10
x3 = x1 + x2;                       % 3. Suma
rng(42);                            % semilla para reproducibilidad
x4 = x3 + randn(size(t));           % 4. Suma + ruido blanco gaussiano (var = 1)

% 5. Senal de audio (sin senal de respaldo: si no esta, el script se detiene)
rutas = {fullfile('muestras_guitarra','acoustic.wav'), 'acoustic.wav'};
archivo = '';
for k = 1:numel(rutas)
    if isfile(rutas{k}); archivo = rutas{k}; break; end
end
if isempty(archivo)
    error('No se encontro acoustic.wav. Ejecute el script desde la raiz del repositorio.');
end
[x5, Fs5] = audioread(archivo);
x5 = mean(x5, 2).';                 % a mono y vector fila

senales = {x1, x2, x3, x4, x5};
fsList  = [Fs, Fs, Fs, Fs, Fs5];
titulos = {'Senoidal 200 Hz (A = 1)', 'Senoidal 500 Hz (A = 10)', ...
    'Suma 200 Hz + 500 Hz', 'Suma + ruido blanco gaussiano', ...
    'Senal acoustic.wav'};
archivos = {'fourier_x1', 'fourier_x2', 'fourier_x3', 'fourier_x4', 'fourier_x5'};
fMax     = [1000, 1000, 1000, Fs/2, 5000];   % limite del eje de frecuencia [Hz]
escalaDB = [false, false, false, true, true]; % FFT en dB para ruido y audio

%% ---------------------- FFT y espectrograma -----------------------------
fprintf('%-32s %12s %12s %14s\n', 'Senal', 'P (tiempo)', 'P (Parseval)', 'Pico FFT [Hz]');
for i = 1:numel(senales)
    x  = senales{i};
    fs = fsList(i);
    N  = numel(x);

    % --- Espectro unilateral de amplitud ---
    X  = fft(x);
    P1 = abs(X(1:floor(N/2)+1))/N;
    P1(2:end-1) = 2*P1(2:end-1);
    f  = (0:floor(N/2))*fs/N;

    % --- Potencia: dominio del tiempo vs. Parseval ---
    Pt = mean(x.^2);
    Pf = sum(abs(X).^2)/N^2;
    [~, iPk] = max(P1(2:end)); fPk = f(iPk+1);   % pico ignorando DC
    fprintf('%-32s %12.4f %12.4f %14.1f\n', titulos{i}, Pt, Pf, fPk);

    % --- Espectrograma (STFT, ventana de Hann) ---
    win  = 4096;                  % ~93 ms -> resolucion ~10.8 Hz
    nov  = round(0.75*win);       % 75 % de traslape
    nfft = 8192;
    [S, F, T] = spectrogram(x, hann(win), nov, nfft, fs);
    SdB = 10*log10(abs(S).^2 + eps);

    % --- Figura ---
    fig = figure('Name', titulos{i}, 'Color', 'w', 'Units', 'centimeters', ...
        'Position', [2 2 16 14]);
    try theme(fig, 'light'); catch; end   % fuerza tema claro (R2025a+)

    subplot(2,1,1);
    if escalaDB(i)
        plot(f, 20*log10(P1 + eps), 'b', 'LineWidth', 1);
        ylabel('Amplitud [dB]');
    else
        plot(f, P1, 'b', 'LineWidth', 1.2);
        ylabel('Amplitud');
    end
    xlim([0 fMax(i)]); grid on;
    xlabel('Frecuencia [Hz]');
    title(['FFT: ' titulos{i}]);

    subplot(2,1,2);
    imagesc(T, F, SdB); axis xy;
    ylim([0 fMax(i)]);
    colormap(parula);
    pk = max(SdB(:)); caxis([pk-80 pk]);  % rango dinamico de 80 dB
    cb = colorbar; ylabel(cb, 'Potencia [dB]');
    xlabel('Tiempo [s]'); ylabel('Frecuencia [Hz]');
    title(['Espectrograma: ' titulos{i}]);

    exportgraphics(fig, fullfile(outDir, [archivos{i} '.pdf']), 'ContentType', 'vector');
end

fprintf('\nFiguras exportadas en la carpeta "%s".\n', outDir);