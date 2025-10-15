function postCue(wPtr, targetLocation, stimNum)
global params;

% cuedLocation is the location of the stimulus that is cued. The post cue line will be from the 
% center of the screen (postCueVar.center, can be updated in the defs to
% the cued location. The length of the line is defined by the defs postCueVar.size.

% x1 = params.postCueVar.centerPix(stimNum,1);
% y1 = params.postCueVar.centerPix(stimNum,2);
% %total distance, from center to location of cued stimuli
% distance = sqrt((x1-targetLocation(1))^2 + (y1-targetLocation(2))^2); 
% 
% prop = params.postCueVar.sizePix/distance;
% 
% postCuex2 = [prop*x1 + (1-prop)*targetLocation(1)];
% postCuey2 = [prop*y1 + (1-prop)*targetLocation(2)];
% 
% %To DO: with new subjects use correct version below:
% %postCuex2 = [(1-prop)*x1 + (prop)*targetLocation(1)];
% %postCuey2 = [(1-prop)*y1 + (prop)*targetLocation(2)];

if params.gabor.numStim == 2
    if targetLocation == 1
        Screen('DrawLine',wPtr, params.postCue.color, params.postCue.rectPix1(1), params.postCue.rectPix1(2), params.postCue.rectPix1(3), params.postCue.rectPix1(4), params.postCue.penWidthPix);
    elseif targetLocation == 2
        Screen('DrawLine',wPtr, params.postCue.color, params.postCue.rectPix2(1), params.postCue.rectPix2(2), params.postCue.rectPix2(3), params.postCue.rectPix2(4), params.postCue.penWidthPix);
    end
elseif params.gabor.numStim ==1
    %don't present postcue
end

