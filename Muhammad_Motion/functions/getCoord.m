function [x,y] = getCoord
%
% some time in 2004 by Martin Rolfs
global params

if ~params.eye.record,
	[x,y,button] = GetMouse(); % get gaze position from mouse							
else
	evt = Eyelink( 'newestfloatsample');	
	x   = evt.gx(2); %dominant eye should be measured check if 1 is left and 2 is right			
	y   = evt.gy(2);
end