% Parámetros generales
Fs = 8000; % Frecuencia de muestreo
t = 0:1/Fs:1-1/Fs; % Vector de tiempo de 1 segundo de duración

% 1. Señal sinusoidal unitaria de 200 Hz
s1 = sin(2*pi*200*t);

% 2. Señal sinusoidal de amplitud 10 y 500 Hz
s2 = 10*sin(2*pi*500*t);

% 3. Suma de las señales
s3 = s1 + s2;

% 4. Suma con ruido blanco
ruido = randn(size(t)); % Distribución normal
s4 = s3 + ruido;

% 5. Señal de audio (asumiendo que acoustic.wav está en el directorio)
[s5, Fs_audio] = audioread('acoustic.wav');

% --- Análisis con FFT y Espectrograma ---
senales = {s1, s2, s3, s4};
titulos = {'Seno 200Hz', 'Seno 500Hz', 'Suma', 'Suma + Ruido'};

figure;
for i = 1:4
    % FFT
    Y = fft(senales{i});
    L = length(senales{i});
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;

    subplot(4, 2, 2*i-1);
    plot(f, P1);
    title(['Espectro FFT: ' titulos{i}]);
    xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
    xlim([0 1000]); % Limitar vista para apreciar los picos

    % Espectrograma
    subplot(4, 2, 2*i);
    spectrogram(senales{i}, 256, 128, 256, Fs, 'yaxis');
    title(['Espectrograma: ' titulos{i}]);
end