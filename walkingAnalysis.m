close all

% files for different types of walking
testfiles = ["Regular.csv", "Heavier.csv", "Heaviest.csv", "Left_Big_1.csv"];
testfilenames = ["Normal", "Medium Stomping", "Heavy Stomping", "Uneven Gait"];

% files for test subjects
subjectfiles = ["K1.csv", "K2.csv", "Ka1.csv", "Ka3.csv", "S1.csv", ...
    "S2.csv", "R1.csv", "R2.csv", "E1.csv", "E2.csv", "J1.csv", "J2.csv"];
subjectfilenames = ["Subject 1 Normal", "Subject 1 Medium", "Subject 2 Normal", ...
    "Subject 2 Pseudo Stomp", "Subject 3 Normal", "Subject 3 Medium", "Subject 4 Normal", ...
    "Subject 4 Heavy", "Subject 5 Normal", "Subject 5 Heavy", "Subject 6 Normal", "Subject 6 Pseudo Stomp"];
subjectwalktypes = ["Normal", "Medium", "Normal", "Pseudo Stomp", "Normal", ...
    "Medium", "Normal", "Heavy", "Normal", "Heavy", "Normal", "Pseudo Stomp"];

% time stamps to cut off the beginning and end (taking phone out of the pocket, etc.)
cutoffs = [250 1100; 200 1000; 450 1200; 600 1000; 230 700; 200 700; ...
    450 1350; 350 1250; 500 1200; 400 800; 300 1000; 300 900];


% time, x, y, z, absolute
acceleration_index = 4;

% sampling frequency
Fs = 100;

disp("Stomp Scores")
for i=1:size(testfiles, 2)
    data = readmatrix("walking_data\" + testfiles(i));
    data = data(300:end-200,:);
    % graph raw Z-axis acceleration data
    figure
    plot(data(:,1), data(:,acceleration_index))
    title(testfilenames(i))
    xlabel("Time (seconds)")
    ylabel("Acceleration (m/s^2)")
    % compute the Fourier transform
    fouriershifted = fftshift(fft(data(:,acceleration_index)));
    N = size(data, 1);
    frequencies = linspace(-Fs/2, Fs/2 - Fs/N, N) + Fs/(2*N)*mod(N, 2);
    % plot the Fourier transform
    figure
    amplitudes = abs(fouriershifted)/N;
    plot(frequencies, amplitudes)
    title(testfilenames(i))
    xlabel("Frequency (Hz)")
    ylabel("Amplitude")
    % calculate the stomp score
    greater_than_zero = find(frequencies >= 0);
    less_than_ten = find(frequencies <= 10);
    primary_freq_amplitude = max(amplitudes(greater_than_zero(1):less_than_ten(end)));
    secondary_freq_amplitude = max(amplitudes(less_than_ten(end)+1:end));
    stomp_score = round(secondary_freq_amplitude/primary_freq_amplitude * 100, 1);
    disp(testfilenames(i) + ": " + stomp_score)
end

for i=1:size(subjectfiles, 2)
    data = readmatrix("walking_data\" + subjectfiles(i));
    data = data(cutoffs(i, 1):cutoffs(i, 2),:);
    % compute the Fourier transform
    fouriershifted = fftshift(fft(data(:,acceleration_index)));
    N = size(data, 1);
    frequencies = linspace(-Fs/2, Fs/2 - Fs/N, N) + Fs/(2*N)*mod(N, 2);
    % plot the Fourier transform
    figure
    amplitudes = abs(fouriershifted)/N;
    plot(frequencies, amplitudes)
    title(subjectfilenames(i))
    xlabel("Frequency (Hz)")
    ylabel("Amplitude")
    % calculate the stomp score
    greater_than_zero = find(frequencies >= 0);
    less_than_ten = find(frequencies <= 10);
    primary_freq_amplitude = max(amplitudes(greater_than_zero(1):less_than_ten(end)));
    secondary_freq_amplitude = max(amplitudes(less_than_ten(end)+1:end));
    stomp_score = round(secondary_freq_amplitude/primary_freq_amplitude * 100, 1);
    % determine accuracy of the stomp score
    if (((subjectwalktypes(i) == "Normal" || subjectwalktypes(i) == "Pseudo Stomp") && stomp_score <= 35) || ...
            (subjectwalktypes(i) == "Medium" && stomp_score > 35 && stomp_score <= 70) || ...
            (subjectwalktypes(i) == "Heavy" && stomp_score > 70))
        accurate = "Yes";
    else
        accurate = "No";
    end
    % annotate graphs
    annotation_string = {"Stomp Score: " + stomp_score, "Accurate: " + accurate};
    annotation("textbox", [0.2 0.6 0.3 0.3], "String", annotation_string, "FitBoxToText", "on")
end

