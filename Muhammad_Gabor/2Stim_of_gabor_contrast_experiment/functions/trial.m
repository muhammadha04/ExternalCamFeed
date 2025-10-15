function   [respDisc, respEsti, faultyTrial] = trial(wPtr, trialNum,expData, startclut,direc,edfFile, sesNum, el)
global params;
trialAngle1 = expData.angles1(trialNum);
trialAngle2 = expData.angles2(trialNum);
trialContrast = expData.dotCoh(trialNum);
%trialType = expData.trialsType(trialNum);
cuedLocation=expData.cuedStim(trialNum); 
targetLocation = expData.targetStimRnd(trialNum);


faultyTrial=0;
keyIsDown = 0;

if params.eye.record
    Eyelink('StartRecording');
    Eyelink('Message', sprintf('StartTrial_Ses_%s_Trial_%d_direction_%d', sesNum,trialNum,trialAngle));
end 
if params.eye.fixCheck, fixationCheck(sesNum,trialNum,trialAngle,el);end

% timing follows donovan et al 2020 exp 2

%Fixation - trial starts
fixation(wPtr);Screen('Flip', wPtr); 
if params.eye.record, Eyelink('Message', 'Fixation1_on'); end;
WaitSecs(0.3);
if params.eye.record, Eyelink('Message', 'Fixation1_off'); end;

%Precue - Attention or neutral
fixation(wPtr);
preCue(wPtr, cuedLocation); 
Screen('Flip', wPtr);
WaitSecs(params.preCue.dur); % 60 ms

%preStimISI fixation
fixation(wPtr);Screen('Flip', wPtr); 
WaitSecs(params.gabor.preStimDur); % 40 ms

% Stimuli
fixation(wPtr);
%%%%%%preCue(wPtr, cuedLocation); %!!!!!!!!!!!!!!! only to check that
%%%%%%theres  no overlap with stimulus and masking

gaborTrial(wPtr, trialAngle1, trialAngle2, trialContrast)
Screen('Flip', wPtr);
WaitSecs(params.gabor.dur); % 70 ms (shorter than donovan 2020)

% fixation
fixation(wPtr);Screen('Flip', wPtr); 
WaitSecs(params.gabor.postStimDur); % 300 ms

% % postCue 
% fixation(wPtr);
% postCue(wPtr,targetLocation,params.gabor.numStim); %if one stimulus no postcue
% Screen('Flip', wPtr);
% WaitSecs(params.postCue.dur); % 300 ms


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
    correctTrial = checkResp(respDisc, trialAngle1, trialAngle2, targetLocation);
    %correctTrial = 1;
    audFB(correctTrial);
    %WaitSecs(2);;
    respDisc.correct = correctTrial;
% end

% if params.eye.record,
%     Eyelink('ReceiveFile', edfFile, sprintf('%s/%s',folder,edfFile)); 
% end

faultyTrial=0;
keyIsDown = 0;

if params.eye.record
    Eyelink('StartRecording');
    Eyelink('Message', sprintf('StartTrial_Ses_%s_Trial_%d_direction_%d', sesNum,trialNum,trialAngle));
end 
if params.eye.fixCheck, fixationCheck(sesNum,trialNum,trialAngle,el);end

% timing follows donovan et al 2020 exp 2

%Fixation - trial starts
fixation(wPtr);Screen('Flip', wPtr); 
if params.eye.record, Eyelink('Message', 'Fixation1_on'); end;
WaitSecs(0.3);
if params.eye.record, Eyelink('Message', 'Fixation1_off'); end;

%Precue - Attention or neutral
fixation(wPtr);
preCue(wPtr, cuedLocation); 
Screen('Flip', wPtr);
WaitSecs(params.preCue.dur); % 60 ms

%preStimISI fixation
fixation(wPtr);Screen('Flip', wPtr); 
WaitSecs(params.gabor.preStimDur); % 40 ms

% Stimuli
fixation(wPtr);
%%%%%%preCue(wPtr, cuedLocation); %!!!!!!!!!!!!!!! only to check that
%%%%%%theres  no overlap with stimulus and masking

gaborTrial(wPtr, trialAngle1, trialAngle2, trialContrast)
Screen('Flip', wPtr);
WaitSecs(params.gabor.dur); % 70 ms (shorter than donovan 2020)

% fixation
fixation(wPtr);Screen('Flip', wPtr); 
WaitSecs(params.gabor.postStimDur); % 300 ms

% postCue 
% fixation(wPtr);
% postCue(wPtr,targetLocation,params.gabor.numStim); %if one stimulus no postcue
% Screen('Flip', wPtr);
% WaitSecs(params.postCue.dur); % 300 ms


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
    correctTrial = checkResp(respDisc, trialAngle1, trialAngle2, targetLocation);
    %correctTrial = 1;
    audFB(correctTrial);
    %WaitSecs(2);;
    respDisc.correct = correctTrial;
% end

% if params.eye.record,
%     Eyelink('ReceiveFile', edfFile, sprintf('%s/%s',folder,edfFile)); 
% end

