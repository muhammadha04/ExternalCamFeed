
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Task params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expTask = struct( 'taskType',{0});
%taskType - gabor_contrast
%taskType - rdk

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      screen params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screenVar = struct('guess', {0}, 'num', {0}, 'rectPix',{[0 0 1920 1080 ]}, 'dist', {52}, 'size', {[30 54 ]},...
                    'res', {[  1920 1080]},'calib_filename', {'gammaTable.mat'}, 'monRefresh', {60}); %display size in mm
oldResolution=Screen('Resolution', 0) ; 
[width, height]=Screen('DisplaySize',0); %resolution of the monitor
% screenVar = struct('guess', {0}, 'num', {0}, 'rectPix',{[0 0 2234 3440]}, 'dist', {10}, 'size', {[34.4 22.2]},...
%                     'res', {[2234 3440]}, 'calib_filename', {'gammaTable.mat'}, 'monRefresh', {120}); 
% 

%3456 × 2234
% if screenVar.guess
%     screenVar.rectPix = [0 0 Screen('Resolution',screenVar.num).width, Screen('Resolution',screenVar.num).height];
%     screenVar.res = [Screen('Resolution',screenVar.num).width, Screen('Resolution',screenVar.num).height];
%     [w, h]= Screen('DisplaySize', screenVar.num);
%     screenVar.size = [w/10 h/10];
%     screenVar.monRefresh = Screen('FrameRate', screenVar.num);
% end
screenVar.centerPix = [ screenVar.rectPix(3)/2 screenVar.rectPix(4)/2];
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
fixationVar = struct( 'color',{[black black black 255]}, 'penWidthPix', {3}, 'bkColor', screenVar.bkColor,...
                      'sizeCrossDeg', {[0.2 0.2]}, 'colorDisc', {[black black black 255]},'present2ndFix',{1}); 
fixationVar.sizeCrossPix = degs2Pixels(screenVar.res, screenVar.size, screenVar.dist, fixationVar.sizeCrossDeg); % {15}
fixationVar.rectPix = [0 0 fixationVar.sizeCrossDeg(1)*screenVar.degratioX fixationVar.sizeCrossDeg(1)*screenVar.degratioX];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Gabor params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gabor= struct('numStim', {2}, 'StimXDeg',{2}, 'StimYDeg', {2}, 'StimEccDeg', {5}, 'dur', {0.5}, 'SF', {4}, 'preStimDur', {0.04}, 'postStimDur', {0.3}, ...
    'polarAng', {0}, 'GaussSD', 3, 'bkColor', {screenVar.bkColor},'possibleAngels', {[80 100]}, 'cw_ccw',  {[2 1]}, 'boundaryAngle', {90}); 
%CW (1) or CCW (2) from the boundary, for example 3deg is CCW from 0deg
% 3 357 177 183 %%% 2 1 2 1
 
gabor.StimXPix = gabor.StimXDeg * screenVar.degratioX;
gabor.StimYPix = gabor.StimYDeg * screenVar.degratioY;
gabor.StimEccPix = gabor.StimEccDeg * screenVar.degratioX;
gabor.GaussSDPix = gabor.GaussSD *screenVar.degratioX; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Pre Cue params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The experiment is set to either be valid (type 1) or neutral (type 0)
preCue = struct('type', {1}, 'dur', {0.01}); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Neutral precue params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neutralCue = struct('radiusDeg', {0.4}, 'color',{black}, ...
                   'dur', {0.5}, 'dist2centerDeg', {5}); 
sp1 = deg2pix1Dim(neutralCue.radiusDeg, screenVar.degratioX); 
%sp2 = deg2pix1Dim(neutralCue.rectDeg(2), ratioY); 
neutralCue.dist2centerPix = deg2pix1Dim(neutralCue.dist2centerDeg/2, screenVar.degratioY);

neutralCue.rectPix = [0 0 sp1 sp1];
% 
neutralCue.rectPix1 = CenterRectOnPoint([0 0 sp1 sp1], screenVar.centerPix(1),screenVar.centerPix(2)-neutralCue.dist2centerPix);

% neutralCue.rectPix2 = CenterRectOnPoint([0 0 sp1 sp2], neutralCue.locationsPix2(1),neutralCue.locationsPix2(2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Exogenous precue params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preCueExg = struct('radiusDeg', {0.3}, 'color',{black}, 'bkColor', {screenVar.bkColor}, ...
                   'dur', {.01}, 'penWidthPix', {1}, 'dist2stimDeg',{2.55}, 'validity', {1.0}); 
sp1 = deg2pix1Dim(preCueExg.radiusDeg, screenVar.degratioX); 
preCueExg.rectPix = [0 0 sp1 sp1];
preCueExg.dist2stimPix = deg2pix1Dim(preCueExg.dist2stimDeg, screenVar.degratioX);

%left
preCueExg.rectPix1 = CenterRectOnPoint([0 0 sp1 sp1], screenVar.centerPix(1)-gabor.StimEccPix, screenVar.centerPix(2)-neutralCue.dist2centerPix);
%preCueExg.rectPix1 = CenterRectOnPoint([0 0 sp1 sp1], screen   Var.centerPix(1)-preCueExg.dist2stimPix, screenVar.centerPix(2)-gabor.StimEccPix);

%right
preCueExg.rectPix2 = CenterRectOnPoint([0 0 sp1 sp1], screenVar.centerPix(1)+gabor.StimEccPix, screenVar.centerPix(2)-neutralCue.dist2centerPix);
%preCueExg.rectPix2 = CenterRectOnPoint([0 0 sp1 sp1], screenVar.centerPix(1)-preCueExg.dist2stimPix, screenVar.centerPix(2)+gabor.StimEccPix);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %     box params
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% box = struct('sizePixels', {30}, 'color',{white}, 'slopeVpix', {300}, 'slopeHpix',{150},...
%              'bkColor', {screenVar.bkColor}, 'dur', {2}, 'penWidthPix', {5}); 
% box.locationsPix = stim.locationsPix;
% box.rectPix = CenterRectOnPoint([0 0 box.slopeHpix box.slopeVpix], stim.locationsPix(1,1), stim.locationsPix(1,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     post cue params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
postCue = struct('color',{black},'bkColor', {screenVar.bkColor}, 'dur', {0.3}, 'penWidthPix', {5},...
                    'lengthDeg', {1.5}, 'radiusDeg', {.65}); %, 'centerPix', {screenVar.centerPix});
%NOTE: length is proportional to distance of the stimulus (1.0)
postCue.postCueStartDeg = fixationVar.sizeCrossDeg(1)*2;
postCue.postCueStartDegPix = deg2pix1Dim(postCue.postCueStartDeg, screenVar.degratioX);

postCue.centerXdistPix = deg2pix1Dim(postCue.lengthDeg, screenVar.degratioX);

postCue.rectPix1 = [screenVar.centerPix(1)-postCue.postCueStartDegPix, screenVar.centerPix(2), screenVar.centerPix(1)-postCue.centerXdistPix,screenVar.centerPix(2)];
%postCue.rectPix1 = [screenVar.centerPix(1), screenVar.centerPix(2)-postCue.postCueStartDegPix, screenVar.centerPix(1), screenVar.centerPix(2)-postCue.centerXdistPix];

postCue.rectPix2 = [screenVar.centerPix(1)+postCue.postCueStartDegPix, screenVar.centerPix(2), screenVar.centerPix(1)+postCue.centerXdistPix, screenVar.centerPix(2)];

%postCue.centerXdistDeg = postCue.radiusDeg*cosd(gabor.polarAng);
% postCuelocCenter.TL = nan(1,2); postCuelocCenter.TR = nan(1,2); postCuelocCenter.BL = nan(1,2); postCuelocCenter.BR = nan(1,2);
% postCuelocCenter.TL(1) = (screenVar.centerPix(1) - postCueVar.centerXdistPix); postCuelocCenter.TL(2) = (screenVar.centerPix(2) - postCueVar.centerYdistPix);
% postCuelocCenter.TR(1) = (screenVar.centerPix(1) + postCueVar.centerXdistPix); postCuelocCenter.TR(2) = (screenVar.centerPix(2) - postCueVar.centerYdistPix);
% postCuelocCenter.BL(1) = (screenVar.centerPix(1) - postCueVar.centerXdistPix); postCuelocCenter.BL(2) = (screenVar.centerPix(2) + postCueVar.centerYdistPix);
% postCuelocCenter.BR(1) = (screenVar.centerPix(1) + postCueVar.centerXdistPix); postCuelocCenter.BR(2) = (screenVar.centerPix(2) + postCueVar.centerYdistPix);
% 
% postCueVar.centerPix = [postCuelocCenter.TL; 
%                         postCuelocCenter.TR; 
%                         postCuelocCenter.BL; 
%                         postCuelocCenter.BR];
%                     
% postCueVar.endXDeg = postCueVar.lengthDeg*cosd(gabor.polarAng);
% postCueVar.endYDeg = postCueVar.lengthDeg*sind(gabor.polarAng);
% 
% postCueVar.endXPix = deg2pix1Dim(postCueVar.endXDeg,ratioX);
% postCueVar.endYPix = deg2pix1Dim(postCueVar.endYDeg,ratioY);
% 
% postCuelocEnd.TL = nan(1,2); postCuelocEnd.TR = nan(1,2); postCuelocEnd.BL = nan(1,2); postCuelocEnd.BR = nan(1,2);
% postCuelocEnd.TL(1) = (postCueVar.centerPix(1,1) - postCueVar.endXPix); postCuelocEnd.TL(2) = (postCueVar.centerPix(1,2) - postCueVar.endYPix);
% postCuelocEnd.TR(1) = (postCueVar.centerPix(2,1) + postCueVar.endXPix); postCuelocEnd.TR(2) = (postCueVar.centerPix(2,2) - postCueVar.endYPix);
% postCuelocEnd.BL(1) = (postCueVar.centerPix(3,1) - postCueVar.endXPix); postCuelocEnd.BL(2) = (postCueVar.centerPix(3,2) + postCueVar.endYPix);
% postCuelocEnd.BR(1) = (postCueVar.centerPix(4,1) + postCueVar.endXPix); postCuelocEnd.BR(2) = (postCueVar.centerPix(4,2) + postCueVar.endYPix);
% 
% postCueVar.endPix = nan(4,2);
% postCueVar.endPix = [postCuelocEnd.TL; 
%                      postCuelocEnd.TR; 
%                      postCuelocEnd.BL; 
%                      postCuelocEnd.BR];            
%                     
                    
%postCueVar.sizePix = deg2pix(postCueVar.sizeDeg, ratioX); % considers degrees only in x axis


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Stair params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stair = struct( 'runType',{0},'numStaircases', {1}, 'numDownStep',{[2]},...
                'maxThresh', {1}, 'minThresh', {0.01},'minStepsize', {0.003},...
                'startStepsize', {[0.2] },'startValues', {[0.5]});
%[-0.2 -0.39 -0.1] --> get contrast by doing  10.^[-0.2 -0.39 -0.1]
%stair.nonStairCoh = [.5 .2 .6 ];
% [0.6 0.4 0.3 0.1] --- log10  [-0.2218   -0.3979   -0.5229   -1.0000]
%runType can be either 0 - constant stimuli (set coherence below), 1 -
%staircase 2d1u, or 3 quest 
stair.nonStairCoh = [0.5]; %log contrast (if you want to show 0.3 put here -0.5 --- 10^-0.5=0.3
%a = linspace(-2,0, 15)
 %plot(a,10.^a, '.')
 
 
%For mais: 
% closer to 0 is easier. Contrast of 0.4 is -.3979. If you want a higher
% contast (say 0.65) calculate log10(0.65)=  -0.1871 so change
% stair.nonStairCoh =  -0.1871


%q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma,[grain],[range],[plotIt])

pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
stair.QuestStruct=QuestCreate(0,3,pThreshold,beta,delta,gamma);
stair.QuestStruct.normalizePdf=1; % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.


            
%if ~((sum(isnan(stair.nonStairCoh))) == length(stair.nonStairCoh)) && stair.runStair
%    error('if running a staircase, non stair coherence must be NaN');
%end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %      Dot params 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dots = struct( 'color',{black},'sizeInPix', {4});
% numdotsperdeg = 1.65;
% dots.num = round(numdotsperdeg*(pi*(stim.radiusDeg)^2)); % 1 dot per deg/deg
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %      Oval within dots params 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% oval = struct('radiusDegSize',{. 5}, 'color',{[gray gray gray 255]});
% xoval = oval.radiusDegSize*ratioX; 
% yoval = oval.radiusDegSize*ratioY; %radius
% oval.rectPix = [screenVar.centerPix(1)-xoval, screenVar.centerPix(2)-yoval, screenVar.centerPix(1)+xoval, screenVar.centerPix(2)+yoval];
% oval.present = 1; %whether to present the black oval within the circle of dots
% oval.fixation = 1; %whether to present a fixation in the oval or not
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            mouse params 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mouse = struct( 'color',{[black black black 255]},'penWidthPix', {1}, 'radiusDeg', {5},...
                'present',{1}, 'rectDeg', {0.15},'initialPosVar', {25}, 'respWin', {2}); 
mouse.radiusPix = ratioX*mouse.radiusDeg;
mouse.rectPix = ratioX*mouse.rectDeg;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %            boundary params 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% boundary = struct( 'color',{[black black black 255]},'penWidthPix', {2}, 'present',{1}, 'lengthDeg', {0.3}); 
% 
% boundary.innerRadiusPix = stim.radiusPix + 2*screenVar.degratioX;
% outerRadiusDeg = stim.radiusDeg + boundary.lengthDeg;
% boundary.outerRadiusPix = ratioX*outerRadiusDeg;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     response params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KbName('UnifyKeyNames');
responseVar = struct( 'allowedRespKeys', {['1', '2']}, 'dur',{4},'keyEscape', 'ESCAPE', 'percentEstimation', {0});
responseVar.cw_ccw = [1 2]; %first is CW up, 3 down

for i = 1:length(responseVar.allowedRespKeys)
    responseVar.allowedRespKeysCodes(i) = KbName(responseVar.allowedRespKeys(i));
end
% Note that the correctness of the resp will be computed according to the
% index in the array of resp so that allowedRespKeys(i) is the correct
% response of stim.possibleAngels(i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Block params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blockVars = struct('numBlocks', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Trial params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trialVars = struct('numTrialsPerBlock', {60}); 
if mod(trialVars.numTrialsPerBlock,length(gabor.possibleAngels))~=0
    error('number of trials must be a multiplication of the possible angles');
end
trialVars.numTrialstotal = trialVars.numTrialsPerBlock * blockVars.numBlocks;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Save Data params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saveVars = struct('fileName', {'_vertical_gabors_'}, 'expTypeDirName', {'2gabors_contrast_'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Text params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
textVars = struct('color', black, 'bkColor', gray, 'size', 24);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ISI params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ISIVar = struct('postDur', {0.04}); 

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
                'ISIVar', ISIVar, 'eye', eye, 'mouse', mouse, ...
                'stair',stair, 'instruct', instruct, 'gabor', gabor, 'preCue', preCue, 'postCue', postCue, 'preCueExg', preCueExg, 'neutralCue', neutralCue); 
cl = 1;
if cl
    clear white gray black locationL locationR screenVar fixationVar precueExg box postCueVar responseVar ;
    clear trialVars i blockVars fbVars ratio ratioX ratioY sp1 sp2 rc1 ISIVar sqslope hfslp neutralCue boundary stair;
    clear saveVars textVars preCue screenInfo mouse dotInfo eye xres yres test xoval yoval oval dots cl outerRadiusDeg;
end