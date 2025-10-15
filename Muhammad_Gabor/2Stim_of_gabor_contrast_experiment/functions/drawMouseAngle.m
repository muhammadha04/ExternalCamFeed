function respEsti = drawMouseAngle(wPtr)
global params; 
%draws a line from center to some random degree around main degree
t1 = GetSecs();
rang = params.gabor.boundaryAngle(1)+params.mouse.initialPosVar*(rand(1)-0.5);
randAngle = mod(rang,360);
[x0,y0] = pol2cart(pi*(randAngle+180)/180,params.mouse.radiusPix);
x = x0 + params.screenVar.centerPix(2); x2 = -x0 + params.screenVar.centerPix(2);
y = y0 + params.screenVar.centerPix(1); y2 = -y0 + params.screenVar.centerPix(1);
ShowCursor('Hand', wPtr)
SetMouse(500,500, 0); 
%SetMouse(params.screenVar.centerPix(2), params.screenVar.centerPix(1), 0); 
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

t2=t1;
while (sum(buttons)==0)&& (t2-t1)<params.mouse.respWin%|| keyIsDown==0
    t2 = GetSecs(); 
    
    [x_output,y_output,buttons] = GetMouse(wPtr); 
    xdeg=x_output-params.screenVar.centerPix(2); 
    ydeg=y_output-params.screenVar.centerPix(1);
    [angleRad, rad] = cart2pol(xdeg,ydeg);
    [x0,y0] = pol2cart(angleRad,params.mouse.radiusPix);
    x = x0 + params.screenVar.centerPix(2); x2 = -x0 + params.screenVar.centerPix(2);
    y = y0 + params.screenVar.centerPix(1); y2 = -y0 + params.screenVar.centerPix(1);
    Screen('DrawLine',wPtr,params.mouse.color,x,y,x2, y2,params.mouse.penWidthPix);
    Screen('FillRect',wPtr,params.mouse.color,[x-params.mouse.rectPix, y-params.mouse.rectPix,x+params.mouse.rectPix, y+params.mouse.rectPix]);
    Screen('Flip', wPtr);
    %SetMouse(params.screenVar.centerPix(1)+x0, params.screenVar.centerPix(2)+y0, wPtr); 
    [keyIsDown,secs2,keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE')),  
        Screen('CloseAll'); sca; error('Experiment stopped by user!'); 
    end

end
angleRad
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

%HideCursor;