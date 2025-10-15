function expEndDisp(wPtr)
global params;

instruct = 'Experiment ended. Thank you for your participation!';
Screen('TextSize', wPtr, params.textVars.size);
Screen('TextColor', wPtr, params.textVars.color);
Screen('TextBackgroundColor',wPtr, params.textVars.bkColor );

Screen('DrawText', wPtr, instruct, params.screenVar.centerPix(1)-350, params.screenVar.centerPix(2));
Screen('Flip', wPtr);

WaitSecs(2); 