function result = My2DGauss_nonSym(pixels,mean, sd)

    x1 = [-2*pi: 4*pi/pixels(1) : 2*pi - 4*pi/pixels(1)];
    y1 = (-(x1-mean).^2) /(2*sd^2);
    f1 = (1/(sd*sqrt(2*pi))) * exp(y1);
    
    f1 = f1/max(f1) - min(f1);
    
    x2 = [-2*pi: 4*pi/pixels(2) : 2*pi - 4*pi/pixels(2)];
    y2 = (-(x2-mean).^2) /(2*sd^2);
    f2 = (1/(sd*sqrt(2*pi))) * exp(y2);
    
    f2 = f2/max(f2) - min(f2);
        
    result = f1'*f2;
    
    