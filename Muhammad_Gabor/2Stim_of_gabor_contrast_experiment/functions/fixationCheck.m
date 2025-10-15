function fixationCheck(sesNum,trialNum,trialAngel,el)
global params;

[x,y] = getCoord; % get coordinates from mouse (dummy mode) or gaze (eyelink on)
t1 = getSecs(); t0 = t1;
time = 0; timeTooLong =0;

%We want the subject to fixate continously for a specific time. If subject
%breaks fixation then he needs to re-fixate for the same amount of time. 
while time<params.eye.fixRequiredSecs
    % check fixation in a circular area
    if sqrt((x-params.screenVar.centerPix(1))^2+(y-params.screenVar.centerPix(2))^2)>params.eye.fixCheckRadiusPix	
        t1 = getSecs(); %if fixation broke restart clock 
        disp('fix break')
    end
    if (timeTooLong>params.eye.fixLongGoCalbirate)&& params.eye.record
        Eyelink('StopRecording'); Eyelink('CloseFile'); 
        cal = EyelinkDoTrackerSetup(el); WaitSecs(2);
        Eyelink('StartRecording');
        Eyelink('Message', sprintf('StartTrial_Ses_%s_Trial_%d_direction_%d', sesNum,trialNum,trialAngel));
    end
    [x,y] = getCoord;
    t2 = getSecs();
    time = t2-t1;
    timeTooLong = t2-t0;
end