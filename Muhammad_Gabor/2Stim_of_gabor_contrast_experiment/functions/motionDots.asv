function [allPos, dircs] = motionDots(startclut,trialAngel, wPtr);
global params; 
%AssertOpenGL;
Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('Flip', wPtr,0,dontclear);
%KillUpdateProcess;


    
% % % priorityLevel = MaxPriority(curWindow,'KbCheck');
% % % Priority(priorityLevel);
% % % THE MAIN LOOP
for frame=1:totalFrames  
    allDots = [allPosPix.x(:,frame), allPosPix.y(:,frame)]';
    allDots = allDots-repmat(params.screenVar.centerPix', 1, length(allDots));
    Screen('Flip', wPtr,0,0);    
    Screen('DrawDots', wPtr, allDots, params.dots.sizeInPix, [255 255 255], params.screenVar.centerPix,1);
    Screen('DrawingFinished',wPtr,0);
end

