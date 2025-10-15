 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      screen params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screenVar = struct('num', {max(Screen('Screens'))}, 'rectPix',{[0 0 1920 1080]}, 'dist', {52}, 'size', {[54 30]},...
                    'res', {[1920 1080 ]}, 'calib_filename', {'gammaTable_sarit.mat'}); 
screenVar.centerPix = [screenVar.rectPix(3)/2 screenVar.rectPix(4)/2];
screenVar.monRefresh = 60;
white = 255; black = 0;
%     % In a new screen, run:
%      test = Sc reen('OpenWindow', screenVar.num, [], [0 0 1 1]); 
%      white = WhiteIndex(test);
%      black = BlackIndex(test);
%      Screen('Resolutions', screenVar.num)
%      screenVar.monRefresh = Screen('GetFlipInterval', test); % seconds per frame
%      Screen('CloseAll');
gray = (white+black)/2; 
screenVar.bkColor = gray; screenVar.black = black; screenVar.white = white;

%Compute deg to pixels ratio:
ratio = degs2Pixels(screenVar.res, screenVar.size, screenVar.dist, [1 1]);
ratioX = ratio(1); ratioY = ratio(2);
screenVar.degratioX = ratioX; screenVar.ppd = ratioX; 
screenVar.degratioY = ratioY; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            fixation params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw fixation cross, sizeCross is the cross size,
% and sizeRect is the size of the rect surronding the cross
fixationVar = struct( 'color',{[black black black 255]},'dur', {0.5}, 'penWidthPix', {2.5}, 'bkColor', screenVar.bkColor,...
                      'sizeCrossDeg', {[0.2 0.2]}, 'colorDisc', {[black black black 255]},'present2ndFix',{1}); 
fixationVar.sizeCrossPix = degs2Pixels(screenVar.res, screenVar.size, screenVar.dist, fixationVar.sizeCrossDeg); % {15}
fixationVar.rectPix = [0 0 fixationVar.sizeCrossDeg(1)*screenVar.degratioX fixationVar.sizeCrossDeg(2)*screenVar.degratioY];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      stimuli params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stim = struct('dur', {.3  }, 'possibleAngels', {[310 330]},'boundaryAngle', {[320 320]},...
    'radiusDeg',{8}, 'bkColor', {gray}, 'speedDegPerSec', {15},'lifetime', {1}, 'limitLifetime', {0.05});
% [3 357 183 177]
%cw/ccw: Note, response is encoded in responseVar.cw_ccw = [1 2]. Any changes must be done there as well
stim.cw_ccw = [1 2]; %CCW (1) or CW (2) from the boundary, for example 3deg is CCW from 0deg
% 3 357 177 183 %%% 2 1 2 1
% [0 0 180 180] || [10 350 190 170] || [2 1 1 2]

stim.boundaryAngleRad = stim.boundaryAngle*pi/180;
% speed = visual degreee per per second; num =# of dots; coh=propotion moving in designated direction; 
% diam = diameter of circle of dots in visual degrees; lifetime = logical, are dots limited life time or not
% limitLifetime = proportion of dots which will be randomly replaced in  each frame
% TRAIN WITH DISCRIMINATION: till coh .3 
% 9 350 189 170;;0 0 180 180 ;;2 1 1 2

% TRAIN WITH ESTIMATION: till coh 0.3
% 100 80 277 259;; 90 90 270 270;;

% angles should be between 0 and 359
        
stim.radiusPix = deg2pix1Dim(stim.radiusDeg, ratioX);
stim.speedDegPerMsec = stim.speedDegPerSec/1000;
stim.durInFrames = round(stim.dur*screenVar.monRefresh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Stair params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stair = struct( 'runType',{1},'numStaircases', {2}, 'numDownStep',{[2 2]},...
                'maxThresh', {1}, 'minThresh', {.03},'minStepsize', {.03},...
                'startStepsize', {[.1 .1 ] },'startValues', {[0.85 0.70 ]});
%stair.nonStairCoh = [.5 .2 .6 ];
%runType can be either 0 - constant stimuli (set coherence below), 1 -
%staircase 2d1u, or 3 quest 
stair.nonStairCoh = [0.2 ];

%q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,[grain],[range],[plotIt])

pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
stair.QuestStruct=QuestCreate(0,3,pThreshold,beta,delta,gamma);
stair.QuestStruct.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.


            
%if ~((sum(isnan(stair.nonStairCoh))) == length(stair.nonStairCoh)) && stair.runStair
%    error('if running a staircase, non stair coherence must be NaN');
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Dot params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dots = struct( 'color',{black},'sizeInPix', {4});
numdotsperdeg = 1.65;
dots.num = round(numdotsperdeg*(pi*(stim.radiusDeg)^2)); % 1 dot per deg/deg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Oval within dots params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oval = struct('radiusDegSize',{.75}, 'color',{[gray gray gray 255]});
xoval = oval.radiusDegSize*ratioX; 
yoval = oval.radiusDegSize*ratioY; %radius
oval.rectPix = [screenVar.centerPix(1)-xoval, screenVar.centerPix(2)-yoval, screenVar.centerPix(1)+xoval, screenVar.centerPix(2)+yoval];
oval.present = 1; %whether to present the black oval within the circle of dots
oval.fixation = 1; %whether to present a fixation in the oval or not

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            mouse params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mouse = struct( 'color',{[black black black 255]},'penWidthPix', {1}, 'radiusDeg', {5},...
                'present',{1}, 'rectDeg', {0.15},'initialPosVar', {25}); 
mouse.radiusPix = ratioX*mouse.radiusDeg;
mouse.rectPix = ratioX*mouse.rectDeg;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            boundary params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
boundary = struct( 'color',{[black black black 255]},'penWidthPix', {2}, 'present',{1}, 'lengthDeg', {0.3}); 

boundary.innerRadiusPix = stim.radiusPix + 2*screenVar.degratioX;
outerRadiusDeg = stim.radiusDeg + boundary.lengthDeg;
boundary.outerRadiusPix = ratioX*outerRadiusDeg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     response params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KbName('UnifyKeyNames');
responseVar = struct( 'allowedRespKeys', {['6', '3']}, 'dur',{2},'keyEscape', 'ESCAPE', 'percentEstimation', {0});
responseVar.cw_ccw = [1 2]; %6 up, 3 down

for i = 1:length(responseVar.allowedRespKeys)
    responseVar.allowedRespKeysCodes(i) = KbName(responseVar.allowedRespKeys(i));
end
% Note that the correctness of the resp will be computed according to the
% index in the array of resp so that allowedRespKeys(i) is the correct
% response of stim.possibleAngels(i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Block params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blockVars = struct('numBlocks',1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Trial params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialVars = struct('numTrialsPerBlock', {120}); 
if mod(trialVars.numTrialsPerBlock,length(stim.possibleAngels))~=0
    error('number of trials must be a multiplication of the possible angles');
end
trialVars.numTrialstotal = trialVars.numTrialsPerBlock * blockVars.numBlocks;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Save Data params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saveVars = struct('fileName', {'Oblique_Staircase_'}, 'expTypeDirName', {'Exposure_Exp'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Text params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
textVars = struct('color', black, 'bkColor', gray, 'size', 24);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ISI params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ISIVar = struct('preDur',{0.5}, 'postDur', {0.7}); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Feedback params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fbVars = struct('dur', {0.1}, 'high', {1250}, 'low', {200},'positiveFeedback', {1},'negativeFeedback' ,{1}); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     eye params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eye = struct('record',{0}, 'fixCheck',{0}, 'fixRequiredSecs', {0.2}, 'fixCheckRadiusDeg', {2},...
                'fixLongGoCalbirate', {2}); 
% record (1) or not to record (0)
%If recording set that there will be a second fixation because transfering
%the files takes time and we want to present a fixation when that happens
eye.fixCheckRadiusPix = ratioX*eye.fixCheckRadiusDeg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     instructions params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
instruct = struct('text',{" Please indicate if the overall motion direction of the dots was \n up or down from the boundary"}); 

%-------------------------------------------------------------------------%
%----------------------%%%%%%%%%%%%%%%%%%%--------------------------------%
%                        TOTAL ALL params                                 %
%----------------------%%%%%%%%%%%%%%%%%%%--------------------------------%
%-------------------------------------------------------------------------%

global params;
params = struct('screenVar', screenVar, 'trialVars', trialVars, 'blockVars', blockVars, 'saveVars', saveVars,...
                'fixationVar', fixationVar,'textVars',textVars, 'responseVar', responseVar, 'fbVars', fbVars,...
                'stim', stim, 'ISIVar', ISIVar, 'dots', dots, 'eye', eye, 'oval', oval, 'mouse', mouse, ...
                'boundary', boundary, 'stair',stair, 'instruct', instruct); 
cl = 1;
if cl
    clear white gray black locationL locationR screenVar stim fixationVar precueExg box postCueVar responseVar ;
    clear trialVars i blockVars fbVars ratio ratioX ratioY sp1 sp2 rc1 ISIVar sqslope hfslp neutralCue boundary stair;
    clear saveVars textVars preCue screenInfo mouse dotInfo eye xres yres test xoval yoval oval dots cl outerRadiusDeg;
end
    