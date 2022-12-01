close all

filenames = ["Normal_1.csv", "Normal_2.csv", "Normal_3.csv", "Left_Big_1.csv", ...
    "Left_Big_2.csv", "Right_Big_2.csv", "Right_Big_2.csv", "Shuffle_1.csv", ...
    "Shuffle_2.csv", "Stomp_1.csv", "Stomp_2.csv", "Stumble_1.csv", "Stumble_2.csv", ...
    "Waddle_1.csv", "Waddle_2.csv"];

% time, x, y, z, absolute
acceleration_index = 5;

Fs = 100;

for i=1:size(filenames, 2)
    data = readmatrix("walking_data\" + filenames(i));
    data = data(300:end-200,:);
    %figure
    %plot(data(:,1), data(:,acceleration_index))
    fouriershifted = fftshift(fft(data(:,acceleration_index)));
    N = size(data, 1);
    frequencies = linspace(-Fs/2, Fs/2 - Fs/N, N) + Fs/(2*N)*mod(N, 2);
    figure
    plot(frequencies, abs(fouriershifted))
    title(filenames(i))
end