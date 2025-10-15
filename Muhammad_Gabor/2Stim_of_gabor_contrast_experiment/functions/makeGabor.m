function [gabor] = makeGabor(outer,gaborRadiusPix,gaborGaussSDPix,gaborPhasePix,gaborSFPix,l_mean,contrast)
    xx = linspace(-gaborRadiusPix, gaborRadiusPix, (outer * 2));
    [x, y] = meshgrid(xx);   
    gauss = exp( -(x.^2+y.^2)./(2*gaborGaussSDPix^2));
    gauss = gauss/max(gauss(:));
    sineGrating=sin(x*2*pi*gaborSFPix+gaborPhasePix);
    gratingMat(:,:,1) = l_mean+( l_mean*contrast*sineGrating.*gauss);
    gabor = cast(gratingMat,'uint8');

end