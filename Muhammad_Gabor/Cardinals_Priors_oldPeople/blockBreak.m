function blockBreak(wPtr, b)
global params;

if b==1
    Screen('TextBackgroundColor',wPtr, params.textVars.bkColor );
    if params.responseVar.percentEstimation ==0
        %discrimination
        [img, ~, alpha] = imread('img_folder/disc1.png');          
    else
        % estimation
        [img, ~, alpha] = imread('img_folder/esti1.png');  
    end
    
    texture1 = Screen('MakeTexture', wPtr, img);
    smallIm = [150 150 938 1090];
    Screen('DrawTexture', wPtr, texture1, [] );
    Screen('Flip', wPtr);
    WaitSecs(2);

    keyIsDown = 0;
    while (~keyIsDown)
        [keyIsDown,secs,keyCode] = KbCheck;              
              if keyCode(KbName('Space')),  keyIsDown = 1; break; else keyIsDown =0;  end   
    end

elseif b>1
    instruct = sprintf('Block number %d ended. Press space!', b-1);

    Screen('TextSize', wPtr, params.textVars.size);
    Screen('TextColor', wPtr, params.textVars.color);
    Screen('TextBackgroundColor',wPtr, params.textVars.bkColor );

    Screen('DrawText', wPtr, instruct, params.screenVar.centerPix(1)-350, params.screenVar.centerPix(2));
    [img, ~, alpha] = imread('img_folder/disc2.png');

    if params.responseVar.percentEstimation ==0
        %discrimination
        b
        if b>1&& b<params.blockVars.numBlocks
            [img, ~, alpha] = imread('img_folder/disc2.png');
        elseif b==params.blockVars.numBlocks+1
          [img, ~, alpha] = imread('img_folder/disc3.png');  
        end
    else
        % estimation
        b
        if b>1&& b<params.blockVars.numBlocks
            [img, ~, alpha] = imread('img_folder/esti2.png');
        elseif b==params.blockVars.numBlocks+1
          [img, ~, alpha] = imread('img_folder/esti3.png');  
        end
    end
    
    texture1 = Screen('MakeTexture', wPtr, img);
    smallIm = [150 150 938 1090];
    Screen('DrawTexture', wPtr, texture1, [] );
    Screen('Flip', wPtr);
    WaitSecs(2);

    keyIsDown = 0;
    while (~keyIsDown)
        [keyIsDown,secs,keyCode] = KbCheck;              
              if keyCode(KbName('Space')),  keyIsDown = 1; break; else keyIsDown =0;  end   
    end
end