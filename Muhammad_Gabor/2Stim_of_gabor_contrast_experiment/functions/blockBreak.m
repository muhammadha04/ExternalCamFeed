function blockBreak(wPtr, b)
global params;

instruct = sprintf('Block number %d ended. Press space!', b-1);

Screen('TextSize', wPtr, params.textVars.size);
Screen('TextColor', wPtr, params.textVars.color);
Screen('TextBackgroundColor',wPtr, params.textVars.bkColor );

%Screen('DrawText', wPtr, instruct, params.screenVar.centerPix(2)-350, params.screenVar.centerPix(1));
%[img, ~, alpha] = imread('img_folder/disc2.png');

if b==params.blockVars.numBlocks+1
      [img, ~, alpha] = imread('img_folder2/Arabic4.jpg');
      texture1 = Screen('MakeTexture', wPtr, img);
      s = size(img);
      smallIm = [params.screenVar.centerPix(1)-s(2)/2, params.screenVar.centerPix(2)-s(1)/2, params.screenVar.centerPix(1)+s(2)/2, params.screenVar.centerPix(2)+s(1)/2];
      Screen('DrawTexture', wPtr, texture1, [], smallIm );
      Screen('Flip', wPtr);
else
    [img, ~, alpha] = imread('img_folder2/Arabic_break.jpg');
    texture1 = Screen('MakeTexture', wPtr, img);
    s = size(img);
    smallIm = [params.screenVar.centerPix(1)-s(2)/2, params.screenVar.centerPix(2)-s(1)/2, params.screenVar.centerPix(1)+s(2)/2, params.screenVar.centerPix(2)+s(1)/2];
    Screen('DrawTexture', wPtr, texture1, [], smallIm );
    Screen('Flip', wPtr);
end



WaitSecs(2);
keyIsDown = 0;
while (~keyIsDown)
    [keyIsDown,secs,keyCode] = KbCheck;              
          if keyCode(KbName('Space')),  keyIsDown = 1; break; else keyIsDown =0;  end   
end
