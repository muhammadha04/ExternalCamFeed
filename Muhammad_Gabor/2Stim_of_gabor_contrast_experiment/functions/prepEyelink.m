function el = prepEyelink(wPtr)
global params;
el = 0;
if params.eye.record 
    [result dummy] = EyelinkInit(); 
    if result 
        el = EyelinkInitDefaults(wPtr);
        el.backgroundcolour = params.screenVar.bkColor;
        el.foregroundcolour = params.dots.color;
        Eyelink('Command', 'file_sample_data = LEFT,RIGHT,GAZE,AREA');
    else  
        fprintf('Couldn''t initialize connection with eyetracker! Switch to dummy...\n'); 
        [dummy] = Eyelink('initializedummy');
        el = EyelinkInitDefaults(wPtr);
    end
end

% status = Eyelink('isconnected');
% switch status
%     case -1
%         fprintf(1, 'Eyelink in dummymode.\n\n');
%     case  0
%         fprintf(1, 'Eyelink not connected.\n\n');
%     case  1
%         fprintf(1, 'Eyelink connected.\n\n');
% end
