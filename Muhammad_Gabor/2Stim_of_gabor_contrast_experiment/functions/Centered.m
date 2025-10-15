function [Coordinates]= Centered(resx,resy,xLocDis, yLocDis, sizex,sizey);
    % [Coordinates]= Centered(resx,resy,xLocDis, yLocDis, sizex,sizey);
    UpLeftScrX=(resx/2)+xLocDis; 
    CenteredX=UpLeftScrX-round(sizex/2);
    CenteredObjDimX=CenteredX+sizex;
    UpLeftScrY=round(resy/2)+yLocDis;
    CenteredY=UpLeftScrY-(sizey/2);
    CenteredObjDimY=CenteredY+sizey; 
    Coordinates=[CenteredX; CenteredY; CenteredObjDimX; CenteredObjDimY]';
end