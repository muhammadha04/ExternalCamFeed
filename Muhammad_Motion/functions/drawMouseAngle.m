function respEsti = drawMouseAngle(wPtr, trialAngle)
global params; 
%draws a line from center to some random degree around main degree
ShowCursor; 
t1 = GetSecs();
randAngle = mod(params.stim.boundaryAngle(1)+params.mouse.initialPosVar*rand(1),360);
[x0,y0] = pol2cart(pi*(randAngle+180)/180,params.mouse.radiusPix);
x = x0 + params.screenVar.centerPix(1); x2 = -x0 + params.screenVar.centerPix(1);
y = y0 + params.screenVar.centerPix(2); y2 = -y0 + params.screenVar.centerPix(2);
SetMouse(round(x), round(y), wPtr); 
%SetMouse(params.screenVar.centerPix(1), params.screenVar.centerPix(2), wPtr); 
%SetMouse(x, y, wPtr); 
Screen('DrawLine',wPtr,params.mouse.color,x,y,x2, y2,params.mouse.penWidthPix);
Screen('FillRect',wPtr,params.mouse.color,[x-params.mouse.rectPix, y-params.mouse.rectPix,x+params.mouse.rectPix, y+params.mouse.rectPix ]);
Screen('Flip', wPtr); 
[keyIsDown,secs2,keyCode] = KbCheck;
if keyCode(KbName('ESCAPE')),  
    Screen('CloseAll'); sca; error('Experiment stopped by user!'); 
end

angle = randAngle; buttons = 0; angleRad = 0;
[xMove,yMove,buttons] = GetMouse(wPtr); xMove2 = xMove;
while (xMove==xMove2),[keyIsDown,secs2,keyCode] = KbCheck; [xMove2,yMove2,buttons] = GetMouse(wPtr); end
%[keyIsDown,secs2,keyCode] = KbCheck;
t2=t1;

while (sum(buttons)==0)&& (t2-t1)<params.mouse.respWin%|| keyIsDown==0
%     [keyIsDown,secs2,keyCode] = KbCheck;
%     if keyIsDown ==1
%         if keyCode(kbname('ESCAPE')),
%             screen('CloseAll'); error('Experiment stopped by user!');
%         else
%             keyIsDown = 0;
%         end
%     end

    t2 = GetSecs(); 
    
    [x_output,y_output,buttons] = GetMouse(wPtr); 
    xdeg=x_output-params.screenVar.centerPix(1); ydeg=y_output-params.screenVar.centerPix(2);
    [angleRad, rad] = cart2pol(xdeg,ydeg);
    [x0,y0] = pol2cart(angleRad,params.mouse.radiusPix);
    x = x0 + params.screenVar.centerPix(1); x2 = -x0 + params.screenVar.centerPix(1);
    y = y0 + params.screenVar.centerPix(2); y2 = -y0 + params.screenVar.centerPix(2);
    Screen('DrawLine',wPtr,params.mouse.color,x,y,x2, y2,params.mouse.penWidthPix);
    Screen('FillRect',wPtr,params.mouse.color,[x-params.mouse.rectPix, y-params.mouse.rectPix,x+params.mouse.rectPix, y+params.mouse.rectPix]);
    Screen('Flip', wPtr);
    %SetMouse(params.screenVar.centerPix(1)+x0, params.screenVar.centerPix(2)+y0, wPtr); 
    [keyIsDown,secs2,keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE')),  
        Screen('CloseAll'); sca; error('Experiment stopped by user!'); 
    end

end
rt = t2-t1;
if rt>params.mouse.respWin %|| (sum(buttons)==0)
    rt = NaN;
    responseAngle = NaN;
%elseif (sum(buttons)~=0)
else
    responseAngle = mod((angleRad*180/pi)+180,360);
    %responseAngle = 360-angle;
    %responseAngle = abs(angle+180);
    %responseAngle = mod(angle+180, 360);
end

respEsti.rt = rt;
respEsti.respAngle = responseAngle;

HideCursor;