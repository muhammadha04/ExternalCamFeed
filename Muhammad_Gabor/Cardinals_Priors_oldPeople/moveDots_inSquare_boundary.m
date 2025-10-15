function moveDots_inSquare_boundary(startclut,allPosPix, wPtr,trialAngel)
global params; 
Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
if params.boundary.present
    pos = find(trialAngel == params.stim.possibleAngels);
    boundaryAngleRad = params.stim.boundaryAngleRad(pos);
    [h1, v1] = pol2cart(boundaryAngleRad,params.boundary.innerRadiusPix);
    [h2, v2] = pol2cart(boundaryAngleRad,params.boundary.outerRadiusPix);
    h1 = round(h1)+params.screenVar.centerPix(1); v1 = round(v1)+params.screenVar.centerPix(2);
    h2 = round(h2)+params.screenVar.centerPix(1); v2 = round(v2)+params.screenVar.centerPix(2);
    Screen('DrawLine', wPtr, params.boundary.color, h1,v1, h2, v2, params.boundary.penWidthPix); %boundary
end

tic
for frame=1:params.stim.durInFrames      
    allDots = [allPosPix.x(:,frame), allPosPix.y(:,frame)]';
    allDots = allDots-repmat(params.screenVar.centerPix', 1, size(allDots,2));
    c = params.screenVar.centerPix;
    r = params.stim.radiusPix;
    %Screen('FillOval', wPtr ,[250 0 0], round([c(1)-r c(2)-r c(1)+r c(2)+r]));
    Screen('DrawDots', wPtr, allDots, params.dots.sizeInPix, params.dots.color, params.screenVar.centerPix,1);
    if params.oval.present, Screen('FillOval', wPtr, params.oval.color, params.oval.rectPix); end;
   
    if params.oval.fixation, fixation(wPtr); end; 
    
    if params.boundary.present
        Screen('DrawLine', wPtr, params.boundary.color, h1,v1, h2, v2, params.boundary.penWidthPix); %boundary
    end
    
    Screen('DrawingFinished',wPtr,0);
    Screen('Flip', wPtr,0,0); 
end 
toc
Screen('Flip', wPtr,0,0);



