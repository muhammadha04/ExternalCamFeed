function preCue(wPtr, cueLocation)%jitter
global params;

% Inbar - 
params.preCue.type = 0;

switch params.preCue.type 
    
    case 0 % Type is neutral
        Screen('FillOval', wPtr , params.screenVar.black, params.neutralCue.rectPix1);
    case 1, % Type is exogenous
        if cueLocation == 1 % left
            Screen('FillOval', wPtr , params.screenVar.black, params.preCueExg.rectPix1);
        elseif cueLocation ==2 % right
            Screen('FillOval', wPtr , params.screenVar.black, params.preCueExg.rectPix2);
        end
    case 2, % Type is sound
            Fs = 44100;  % Sampling frequency
            duration = 0.083;  % Duration in seconds
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
        if cueLocation == 1 % left
            Screen('FillOval', wPtr , params.screenVar.black, params.preCueExg.rectPix1);
            Out = [zeros(size(t)); pinkNoiseBurst]';  % Output
            sound(Out, Fs)

        elseif cueLocation ==2 % right
            Out = [pinkNoiseBurst;zeros(size(t))]';  % Output
            sound(Out, Fs)
        end    
    end
end

