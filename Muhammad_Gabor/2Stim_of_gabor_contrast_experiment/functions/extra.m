92

function   [respDisc, respEsti, faultyTrial] = trial(wPtr, trialNum,expData, startclut,direc,edfFile, sesNum, el)
global params;
trialAngle1 = expData.angles1(trialNum);
trialAngle2 = expData.angles2(trialNum);
trialContrast = expData.dotCoh(trialNum);
%trialType = expData.trialsType(trialNum);
cuedLocation=expData.cuedStim(trialNum); 
targetLocation = expData.targetStimRnd(trialNum);
 


1
function   [respDisc, respEsti, faultyTrial] = trial(wPtr, trialNum,expData, startclut,direc,edfFile, sesNum, el)
global params;
trialAngle1 = expData.angles1(trialNum);
trialAngle2 = expData.angles2(trialNum);
trialContrast = expData.dotCoh(trialNum);
%trialType = expData.trialsType(trialNum);
cuedLocation=expData.cuedStim(trialNum); 
targetLocation = expData.targetStimRnd(trialNum);