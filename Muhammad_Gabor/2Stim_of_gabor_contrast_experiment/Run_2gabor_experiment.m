  %ways to calculate threshold:
% stair_means1 = [geomean(expData.stairs{1}.reversals(end-7:end)),geomean(expData.stairs{2}.reversals(end-7:end)), geomean(expData.stairs{3}.reversals(end-7:end))]
% stair_means2 = mean([(expData.stairs{1}.threshold),(expData.stairs{2}.threshold), (expData.stairs{3}.threshold)])

%---- RUN EXPERIMENT------%
clear;
Screen('CloseAll'); 
Screen('Preference', 'SkipSyncTests', 1); 
addpath("functions")
%parameter file  

%neutral_two_gabor_parameters_mais100; global params;
%neutral_two_gabor_parameters_mais_training1; global params; 
%neutral_two_gabor_parameters_salam_training1; global params;
muhammad_horizontal; global params;

Screen('Preferences', 'SkipSyncTests',1)
%addpath('/Applications/Psychtoolbox');3
homedir = pwd;   
%initials = 'lf'; sesNum = '1d';       
initials = input('Please enter subject initials (3 characters): \n', 's'); %NOT LONGER THAN 2 CHARACTERS  
sesNum = input('Please enter number of session:\n', 's'); % 0 for pretest and posttest, other number for training sessions
c = clock; 
direc = sprintf('%s/%s/%s/ses%s', homedir,params.saveVars.expTypeDirName,initials,sesNum); 
saveExpFile = sprintf('%s_%s_ses%s_%02d_%02d_%4d_time_%02d_%02d_%02i.mat', params.saveVars.fileName, initials, sesNum, c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
saveExpFile = sprintf('%s/%s',direc,saveExpFile);
mkdir(direc);


wPtr = Screen('OpenWindow',  params.screenVar.num, params.screenVar.bkColor, params.screenVar.rectPix);

%Load  new gamma table to fit the current scre 
startclut =0;
%new_gamma_table = repmat(calib.table, 1, 3);
%if at the lab 
%startclut = Screen('ReadNormalizedGammaTable', params.screenVar.num); 
%load( params.screenVar.calib_filename); 
%load('gammaTable.mat');
%[oldtable, success] = Screen('LoadNormalizedgammaTable',wPtr,gammaTable,[]); 
load('gammaTable.mat');
Screen('LoadNormalizedGammaTable',wPtr, gammaTable, 1);
%Screen('LoadNormalizedGammaTable,wPtr, gammaTable');


Priority(MaxPriority(wPtr));   
instructions(wPtr); 
if params.eye.record, el = prepEyelink(wPtr); end;

respEsti = struct('rt', {[]}, 'respAngles', {[]},'block',{[]});
respDisc = struct('rt', {[]}, 'key', {[]}, 'correct', {[]},'block',{[]});
expData  = struct('angles1',{[]},'angles2',{[]}, 'trialsType',{[]}, 'stairOrder',{[]},'dotCoh',{[]},'block',{[]},'stairs',{[]},...
    'cuedStim', {[]}, 'targetStimRnd', {[]});

%%%% --------------      Start experiment  --------------%%%%%
%HideCursor;
trialNum = 0;
for b = 1:params.blockVars.numBlocks
    expData = calcTrialsVars(expData,b);
    respEsti.block = [respEsti.block b*ones(1,params.trialVars.numTrialsPerBlock,1)];
    respDisc.block = [respDisc.block b*ones(1, params.trialVars.numTrialsPerBlock,1)];
    %if b>1, blockBreak(wPtr, b); end

    if params.eye.record, cal = EyelinkDoTrackerSetup(el); end;
    
    for t = 1: params.trialVars.numTrialsPerBlock
        %if params.stair.runType == 1 && trialNum == 30,  blockBreak(wPtr,b), end;

        trialNum = trialNum +1;
        
        edfFile = sprintf('%st%d.edf',initials,trialNum); el = NaN;
        if params.eye.record
            edfFileStatus = Eyelink('Openfile', edfFile);
            if edfFileStatus ~= 0, fprintf('Cannot open .edf file. Exiting ...'); return; end       
         end
         if isnan(expData.dotCoh(trialNum)) 
             if params.stair.runType ==1
                expData.dotCoh(trialNum) = expData.stairs{b,expData.stairOrder(trialNum)}.threshold;
             elseif params.stair.runType ==3
                 expData.dotCoh(trialNum) = QuestQuantile(params.stair.QuestStruct);
             elseif params.stair.runType ==0
                 expData.dotCoh(trialNum) = 1;
             end
         end
         [respDiscTrial, respEstiTrial, faultyTrial] = trial(wPtr, trialNum,expData, startclut,direc,edfFile, sesNum, el);
         
         respDisc.rt  = [respDisc.rt respDiscTrial.rt];
         respDisc.key = [respDisc.key respDiscTrial.key];
         respDisc.correct = [respDisc.correct respDiscTrial.correct];
         respEsti.respAngles = [respEsti.respAngles respEstiTrial.respAngle];
         respEsti.rt = [respEsti.rt respEstiTrial.rt];
         if params.stair.runType == 1
             expData.stairs{b,expData.stairOrder(trialNum)} = upDownStaircase(expData.stairs{b,expData.stairOrder(trialNum)}, respDiscTrial.correct);
         elseif params.stair.runType == 3
             params.stair.QuestStruct = QuestUpdate(params.stair.QuestStruct,expData.dotCoh(trialNum),respDiscTrial.correct); 
         elseif params.stair.runType ==0
             expData.dotCoh(trialNum) = params.stair.nonStairCoh;
         end

        save(saveExpFile)
        Screen('Close');
    end

end 
blockBreak(wPtr, b+1);

%Screen('LoadNormalizedGammaTable',wPtr,oldtable,[]); 

Screen('Close'); Priority(0);
%expEndDisp(wPtr);   
%Screen('LoadNormalizedGammaTable', wPtr, startclut, []);
Screen('CloseAll'); ShowCursor;
if iscell(expData.stairs)
    thrd = (expData.stairs{1}.threshold); 
    fprintf('Threshold of gabor is %f\n', thrd);   
end

%%%%%-------------     End the experiment    ----------%%%%%

%%%%%------------- Save al  l experiment data ----------%%%%%
cd(direc);
date = sprintf('Date:%02d/%02d/%4d  Time:%02d:%02d:%02i ', c(2),c(3),c(1),c(4),c(5),ceil(c(6)));
save(saveExpFile);
cd(homedir);
%%