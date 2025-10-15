function gaborTrial(wPtr, trialAngle, trialAngle2, noiselevel)
global params; 
%trialContrast = 0.9;
%trialAngle = 30;trialAngle2 = 30;
%logcontrast = -0;
%trialContrast = 10^logcontrast; % 
contrast = -0.2; 
trialContrast = 10^contrast;
%noiseLevel = contrast; 
%wPtr = Screen('OpenWindow',  params.screenVar.num, params.screenVar.bkColor, params.screenVar.rectPix);
Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

stim1ori = trialAngle;
stim2ori = trialAngle2;

cyclesPerImage = 8;
phase_offset = randi([1 100]);
grating = genGrating([params.gabor.StimXPix params.gabor.StimXPix], cyclesPerImage, phase_offset);
%mask = My2DGauss_nonSym([params.gabor.StimXPix params.gabor.StimXPix] ,0,2);
mask = My2DGauss_nonSym([params.gabor.StimXPix params.gabor.StimXPix] ,0,2);

mx= min(size(grating,1),size(mask,1));
my= min(size(grating,2),size(mask,2));

gabor = grating(1:mx,1:my).*mask(1:mx,1:my);
%texture = params.gabor.bkColor + 128*trialContrast.*gabor;
%textureIndex=Screen('MakeTexture', wPtr, texture); 


%%% inbar %%%%
% gabor = grating(1:mx,1:my).*mask(1:mx,1:my);
% texture = params.gabor.bkColor + 128*trialContrast.*gabor;
% 
% noiseLevel = 100; % Adjust this value to control the noise level
% noise = noiseLevel * randn(mx, my); % Generate white noise
% gaborWithNoise = gabor + noise; % Add noise to the Gabor patch
% gaborWithNoise = gaborWithNoise(1:mx,1:my).*mask(1:mx,1:my);
% texture = params.gabor.bkColor + 128*trialContrast.*gaborWithNoise;
% whiteNoise = 2 * rand(mx, my) - 1;  % White noise in the range [-1, 1]
% 
% % Scale the white noise to a desired range (e.g., between -128 and 128)
% noiseScale = 128;  % You can adjust this value
% whiteNoise = noiseScale * whiteNoise;
% 
% % Add the white noise to the Gabor texture
% %gaborWithNoise = gabor + noiseWeight *whiteNoise;
% noiseContrastFactor =0.1
% gaborWithNoise = (1 - noiseContrastFactor) * gabor + noiseContrastFactor * whiteNoise;

%noiselevel =0.5
%2 * rand(mx, my) - 1;

% For the staircase we flip values - For a noise level of 0.2 --> becomes
% 0.8, then we multiply the gabor that has a range of -1 1
noiselevel = abs(noiselevel -1);
%add gaussian normally distributed random numbers with mean 0
%as the noise level increases - the variance (sd) of the noise increases
noise =  noiselevel * (2* randn(size(gabor)) -1);
gaborWithNoise = gabor+noise; 
gaborWithNoise= gaborWithNoise.*mask(1:mx,1:my);

gaborWithNoise = params.gabor.bkColor + 128*trialContrast.* gaborWithNoise;

%added to have mask ontop
%gaborWithNoise = gaborWithNoise(1:mx,1:my).*mask(1:mx,1:my);

%gaborWithNoise= gaborWithNoise.*mask(1:mx,1:my);
% Normalize the final texture (optional, to ensure pixel values stay within a valid range)
%gaborWithNoise = max(min(gaborWithNoise, 255), 0);  % Clamp values between 0 and 255
textureIndex = Screen('MakeTexture', wPtr, gaborWithNoise);


%%% inbar %%%%

%gabor = grating

if params.gabor.numStim == 2
    TargetLoc = Centered(params.screenVar.rectPix(3), params.screenVar.rectPix(4), -params.gabor.StimEccPix, 0, params.gabor.StimXPix, params.gabor.StimXPix); 
    DistLoc = Centered(params.screenVar.rectPix(3), params.screenVar.rectPix(4), params.gabor.StimEccPix, 0, params.gabor.StimXPix, params.gabor.StimXPix);
    Screen('DrawTexture', wPtr, textureIndex, [], TargetLoc, trialAngle);
    Screen('DrawTexture', wPtr, textureIndex, [], DistLoc, trialAngle2);
elseif params.gabor.numStim == 1
    TargetLoc = Centered(params.screenVar.rectPix(3), params.screenVar.rectPix(4), 0, 0, params.gabor.StimXPix, params.gabor.StimXPix); 
    Screen('DrawTexture', wPtr, textureIndex, [], TargetLoc, trialAngle);
    %Screen('DrawTexture', wPtr, textureIndex, [], TargetLoc,350);
end

%Screen('Flip', wPtr,0,0);
