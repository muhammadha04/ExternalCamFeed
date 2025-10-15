function   [respDisc, respEsti, faultyTrial] = trial(wPtr, trialNum,expData, startclut,direc,edfFile, sesNum, el)
global params;
trialAngle1 = expData.angles1(trialNum);
%trialAngle2 = expData.angles2(trialNum);
trialContrast = expData.dotCoh(trialNum);
%trialType = expData.trialsType(trialNum);
%cuedLocation=expData.cuedStim(trialNum); 
%targetLocation = expData.targetStimRnd(trialNum);


faultyTrial=0;
fixation(wPtr); WaitSecs(params.fixationVar.dur);
Screen('Flip', wPtr); keyIsDown = 0;

if params.eye.record
    Eyelink('StartRecording');
    Eyelink('Message', sprintf('StartTrial_Ses_%s_Trial_%d_direction_%d', sesNum,trialNum,trialAngle));
end 
if params.eye.fixCheck, fixationCheck(sesNum,trialNum,trialAngle,el);end

%Fixation - trial starts
fixation(wPtr);Screen('Flip', wPtr); 
if params.eye.record, Eyelink('Message', 'Fixation1_on'); end;
WaitSecs(params.ISIVar.preDur);
if params.eye.record, Eyelink('Message', 'Fixation1_off'); end;

%Precue - Attention
fixation(wPtr);

%preCue(wPtr, cuedLocation);
Screen('Flip', wPtr);
WaitSecs(params.preCue.dur);

%preStimISI fixation
fixation(wPtr);Screen('Flip', wPtr); 
WaitSecs(params.gabor.preStimDur);

% Stimuli
fixation(wPtr);
gaborTrial(startclut, wPtr, trialAngle1, trialAngle1, trialContrast)
Screen('Flip', wPtr);
WaitSecs(params.gabor.dur);

%postStimISI fixation
fixation(wPtr);Screen('Flip', wPtr); 
%[noiseid, noiserect] = CreateProceduralNoise(wPtr, params.gabor.StimXPix, params.gabor.StimXPix);
 noiseimg=(50*randn(round(params.gabor.StimXPix), round(params.gabor.StimXPix)) + 128);
 noisetex = CreateProceduralNoise(wPtr, round(params.gabor.StimXPix), round(params.gabor.StimXPix) ,'ClassicPerlin', [0.5 0.5 0.5 0.0]);

TargetLoc = Centered(params.screenVar.rectPix(3), params.screenVar.rectPix(4), 0, 0, params.gabor.StimXPix, params.gabor.StimXPix); 
Screen('DrawTexture', wPtr, noisetex, [], [500, 500, 500, 500]);
Screen('DrawTexture', wPtr, noisetex, [], [], 0, [], [], [], [], [], [0.2, 0, 0, 0]);

%Screen( 'DrawTextures', wPtr, noiseid);
Screen('Flip', wPtr);
WaitSecs(2);
WaitSecs(params.gabor.postStimDur);

%postCue + fixation
fixation(wPtr);
%postCue(wPtr,targetLocation,params.gabor.numStim); %if one stimulus no postcue
Screen('Flip', wPtr);
%WaitSecs(params.ISIVar.preDur);


% Response + fixation
fixation(wPtr); Screen('Flip', wPtr); 
beep2(800,params.fbVars.dur)
%Screen('Flip', wPtr); 
%if params.eye.record,
%    Eyelink('StopRecording'); Eyelink('CloseFile'); 
%end

respEsti = struct('rt', {[]}, 'respAngle', {[]});
respDisc = struct('rt', {[]}, 'key', {[]}, 'correct', {[]});

% Response
% if trialType == 1,
%     if params.mouse.present, 
%         respEsti = drawMouseAngle(wPtr);
%     else
%         respEsti.rt = NaN; respEsti.respAngles = NaN;
%     end
% elseif trialType == 0,
    %fixation(wPtr, trialType); Screen('Flip', wPtr); 
    fixation(wPtr); Screen('Flip', wPtr); 

    [respDisc, faultyTrial] = response();
    targetLocation = NaN;
    correctTrial = checkResp(respDisc, trialAngle1, trialAngle1, targetLocation);
    audFB(correctTrial);
    %WaitSecs(2);;
    respDisc.correct = correctTrial;
% end

% if params.eye.record,
%     Eyelink('ReceiveFile', edfFile, sprintf('%s/%s',folder,edfFile)); 
% end

