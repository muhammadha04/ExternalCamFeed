function pixels = degs2Pixels(screenRes, screenSize, distance, degs)
% screenRes - the resolution of the monitor
% screenSize - the size of the monitor in cm
% (these values can either be along a single dimension or for both the width and height)
% distance - the viewing distance in cm.
% degs - the amount of degress that should be transformed to a number of pixels

pixSizeCm = screenSize./screenRes; %calculates the size of a pixel in cm

degperpix=(2*atan(pixSizeCm./(2*distance))).*(180/pi);

pixperdeg = 1./degperpix;

pixels = pixperdeg.*degs;