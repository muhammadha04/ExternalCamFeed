f = find(respEsti.respAngles>180);
results = respEsti.respAngles;
results(f) = results(f)-360*ones(1,length(f));
f0 = find(results>90);
results(f0) = NaN;

%angles = [310 330];%[10 350];
angles = [310 330];

numbins = 50; mn = -180; mx = 180;
bins = linspace(mn,mx,numbins);

figure;
for i = 1:size(angles,1)
    f1 = find(expData.angles == angles(i,1));
    f2 = find(expData.angles==angles(i,2));
    
    hist(results(f1),30);
    h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','w')
    %set(h,'FaceColor','r','EdgeColor','w')
    hold on;
    hist(results(f2),30); hold on;
    title(sprintf('Angles %d %d',angles(i,1), angles(i,2)));
    
    for j=1:length(bins)-1
        res1 = results(f1);
        bin = res1>bins(j) & res1<bins(j+1);
        binsRes(i,j,1) = sum(bin);
        res2 = results(f2);
        bin = res2>bins(j) & res2<bins(j+1);
        binsRes(i,j,2) = sum(bin);
    end
    
    means(i,1) = (results(f1));
    means(i,2) = (results(f2));
    corr(i,1) = (sum(results(f1)>0))/length(f1);
    corr(i,2) = (sum(results(f2)<0))/length(f2);
    acc(i) = mean([corr(i,1),corr(i,2)]);
    title(sprintf('Angles %d %d',angles(i,1), angles(i,2)));
end

%%
nm = 30;
figure;
plot(squeeze(binsRes(1,:,1)),'b'); hold on;
plot(squeeze(binsRes(1,:,2)),'r'); 

ylim([0 30]);
set(gca,'XTick',linspace(0,50,nm))
set(gca,'XTickLabel',round(linspace(mn,mx,nm)))
title(sprintf('Angles %d %d',angles(i,1), angles(i,2)));


