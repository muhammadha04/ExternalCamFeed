Fs = 44100;  % Sampling frequency
duration = 1%0.08;  % Duration in seconds
t = linspace(0, duration, Fs*duration);  % Time array

% Generate white noise
whiteNoise = randn(size(t));

% Apply a pink noise filter
B = [0.049922035 -0.095993537 0.050612699 -0.004408786];
A = [1 -2.494956002 2.017265875 -0.522189400];
pinkNoise = filter(B, A, whiteNoise);

% Design a band-pass filter for 0.5 to 15 kHz
fpass = [0.5e3 15e3]/(Fs/2);  % Normalized frequency range
[b, a] = butter(4, fpass, 'bandpass');

% Apply the band-pass filter
pinkNoiseBurst = filter(b, a, pinkNoise);

OutR = [zeros(size(t)); pinkNoiseBurst]';  % Output
OutL = [ pinkNoiseBurst;zeros(size(t))]';  % Output

Out1 = [pinkNoiseBurst; pinkNoiseBurst]';  % Output
%sound(Out, Fs)

%Out = [zeros(size(t)); zeros(size(t)); pinkNoiseBurst]';  % Output

sound(OutL, Fs)


%###########################
Fs = 44100;  % Sampling frequency
duration = 3;  % Duration in seconds
t = linspace(0, duration, Fs*duration);  % Time array

% Generate white noise
whiteNoise = randn(size(t));

% Apply a pink noise filter
B = [0.049922035 -0.095993537 0.050612699 -0.004408786];
A = [1 -2.494956002 2.017265875 -0.522189400];
pinkNoise = filter(B, A, whiteNoise);

% Design a band-pass filter for 20 to 120 Hz (subwoofer range)
fpass = [20 120]/(Fs/2);  % Normalized frequency range
[b, a] = butter(4, fpass, 'bandpass');
subwooferSignal = filter(b, a, pinkNoise);

% Create a three-channel audio signal with the subwoofer signal in the third channel
Out = [zeros(size(t)); zeros(size(t)); subwooferSignal]';

% Write the audio file
audiowrite('subwoofer_signal.wav', Out, Fs);

% Play the audio using audioplayer
player = audioplayer(Out, Fs);
play(player);
