function grating = genGrating(sizePixels,cyclesPerImage,phase_offset)

%Purpose: Generate a sine-wave grating
%Input:     sizePixels: 1X2 matrix, expressing size in pixels in x and y
%           cyclesPerImage: Cycles of the sinusoid over the size in pixels
%           phase_offset: The phase offset
%Output:    Grating: a sinusoidal grating of the correct size with values
%           that vary between -1 and 1

sizePixels = round(sizePixels);
x = 0:sizePixels(2)-1;
f = cyclesPerImage/(sizePixels(2)-1);
fr = f * 2 * pi;
grating = sin(fr*x-phase_offset);
grating = repmat(grating, sizePixels(1), 1);