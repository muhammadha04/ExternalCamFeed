function [crit dprime] = calcDprime(targetSideAll,respAll)
% Hits - target was 1, resp was 1
% FA - target was 2, resp was 1
% Miss - target was 1, resp was 2
% CR - target was 2, resp was 2

% X = NORMINV(P,MU,SIGMA) finds the inverse of the normal cdf with mean,
% MU, and standard deviation, SIGMA.

% Calculate d-prime
% d' is a measure in signal detection theory that measures the
% distance between signal and noise in standard deviation units
crit = NaN;

if size(targetSideAll,1) == 1
    
    pHit = sum(respAll(targetSideAll==1)==1)/length(respAll);
    pFA = sum(respAll(targetSideAll==2)==1)/length(respAll);

    % Convert to Z scores, no error checking    
    zHit = norminv(pHit);
    zFA  = norminv(pFA); 
    dprime = zHit - zFA;
    crit  = (zHit + zFA) ./ (-2) ;
   
elseif size(targetSideAll,1) == 2
    pHit1 = sum(respAll(1,targetSideAll(1,:)==1)==1)/length(respAll)+.00001;
    pFA1 = sum(respAll(1,targetSideAll(1,:)==2)==1)/length(respAll)+.00001;

    pHit2 = sum(respAll(2,targetSideAll(2,:)==1)==1)/length(respAll)+.00001;
    pFA2 = sum(respAll(2,targetSideAll(2,:)==2)==1)/length(respAll)+.00001;
    
    % Convert to Z scores, no error checking
    zHit1 = norminv(pHit1);
    zFA1  = norminv(pFA1);
    
    zHit2 = norminv(pHit2);
    zFA2  = norminv(pFA2);

    dprime1 = zHit1 - zFA1;
    dprime2 = zHit2 - zFA2;

    dprime = nanmean([dprime1, dprime2]);
end
