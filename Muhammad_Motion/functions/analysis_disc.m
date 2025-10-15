function [acc dprimes criteria] = calcDisc_perSubj(expData.angles, respDisc.correct)
resultsCorrect = respDisc.correct';
targetSideAll = expData.angles';

%resultsCorrect = [resultsCorrect ;NaN(23,1)];
angs1 = [2 4 8];
angs2 = [358 356 352];
for i = 1:length(angs1)
    ang1 = angs1(i);%8;%2;
    ang2 = angs2(i);%352;%358;

    angles = expData.angles';
    f1 = (angles==ang1);
    f2 = (angles==ang2);
    fresp = (f1)|(f2);

    respAlltmp = resultsCorrect; 
    targetSideAll(f1) = 1;
    targetSideAll(f2) = 2;

    respAlltmp(angles==ang1&respAlltmp==0) = 2; %miss
    respAlltmp(angles==ang1&respAlltmp==1) = 1; % hits

    respAlltmp(angles==ang2&respAlltmp==1) = 2; %cr
    respAlltmp(angles==ang2&respAlltmp==0) = 1; %fa

    respAll = respAlltmp;

    targetSideAll = targetSideAll';
    [crit dprime] = calcDprime(targetSideAll(fresp),respAll(fresp));
    criteria(i) = crit;
    dprimes(i) = dprime;
    ff = (expData.angles==ang1)|(expData.angles==ang2);
    acc(i) = nanmean(resultsCorrect(ff));
end
acc
dprimes
%%%
% respAlltmp = resultsCorrect; 
% 
% f1 = (expData.angles==4)|(expData.Angels==356);
% acc1 = mean(respAlltmp(f1))
% 
% f2 = (expData.angles==2)|(expData.Angels==358);
% acc2 = mean(respAlltmp(f2))
% 
% f3 = (expData.angles==8)|(expData.Angels==352);
% acc3 = mean(respAlltmp(f3))
% 



