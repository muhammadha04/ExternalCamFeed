function instructions(wPtr)
global params;

%instruct =  params.instruct.text;
%params.instructions_text = "Please indicate the overall motion direction of the dots with the mouse";
instruct = 'Indicate whether the straips are oriented to the left or to the right';
% keys = 'Track the overall direction of the stimulus with your eyes as best as possible.';
% start ='Do not track one individual dot - rather try to track the global motion';
%start = 'Press space to start!';

Screen('TextSize', wPtr, params.textVars.size);
Screen('TextColor', wPtr, params.textVars.color);
Screen('TextBackgroundColor',wPtr, params.textVars.bkColor );

% Screen('DrawText', wPtr, instruct, 20, 70);
% Screen('DrawText', wPtr, keys, params.screenVar.centerPix(1)-350, params.screenVar.centerPix(2));
% Screen('DrawText', wPtr, start, params.screenVar.centerPix(1)-350, params.screenVar.centerPix(2)+150);

[img, ~, alpha] = imread('img_folder2/Arabic1.jpg');
texture1 = Screen('MakeTexture', wPtr, img);
s = size(img);
smallIm = [params.screenVar.centerPix(1)-s(2)/2, params.screenVar.centerPix(2)-s(1)/2, params.screenVar.centerPix(1)+s(2)/2, params.screenVar.centerPix(2)+s(1)/2];
Screen('DrawTexture', wPtr, texture1, [], smallIm );
Screen('Flip', wPtr);
keyIsDown = 0;
while (~keyIsDown)
    [keyIsDown,secs,keyCode] = KbCheck(-1);
    if keyCode(KbName('Space')),  keyIsDown = 1; else keyIsDown =0;  end
   
end
WaitSecs(0.5);

[img, ~, alpha] = imread('img_folder2/Arabic2.jpg');
texture1 = Screen('MakeTexture', wPtr, img);
s = size(img);
smallIm = [params.screenVar.centerPix(1)-s(2)/2, params.screenVar.centerPix(2)-s(1)/2, params.screenVar.centerPix(1)+s(2)/2, params.screenVar.centerPix(2)+s(1)/2];
Screen('DrawTexture', wPtr, texture1, [], smallIm );
Screen('Flip', wPtr);
keyIsDown = 0;
while (~keyIsDown)
    [keyIsDown,secs,keyCode] = KbCheck(-1);
    if keyCode(KbName('Space')),  keyIsDown = 1; else keyIsDown =0;  end
   
end
WaitSecs(0.5);

[img, ~, alpha] = imread('img_folder2/Arabic3.jpg');
texture1 = Screen('MakeTexture', wPtr, img);
s = size(img);
smallIm = [params.screenVar.centerPix(1)-s(2)/2, params.screenVar.centerPix(2)-s(1)/2, params.screenVar.centerPix(1)+s(2)/2, params.screenVar.centerPix(2)+s(1)/2];
Screen('DrawTexture', wPtr, texture1, [], smallIm );
Screen('Flip', wPtr);
keyIsDown = 0;
while (~keyIsDown)
    [keyIsDown,secs,keyCode] = KbCheck(-1);
    if keyCode(KbName('Space')),  keyIsDown = 1; break; else keyIsDown =0;  end
   
end
WaitSecs(0.5);

