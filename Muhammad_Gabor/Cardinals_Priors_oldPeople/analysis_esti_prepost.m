% binsRes1 = binsRes; %pretest
% binsRes2 = binsRes; %pretest

%%
nm = 30; ymax = 30;
figure;
subplot(3,1,1)
plot(squeeze(binsRes1(1,:,1)),'b'); hold on;
plot(squeeze(binsRes1(1,:,2)),'r'); 
plot(squeeze(binsRes2(1,:,1)),':b'); hold on;
plot(squeeze(binsRes2(1,:,2)),':r'); 
ylim([0 ymax]);
set(gca,'XTick',linspace(0,50,nm))
set(gca,'XTickLabel',round(linspace(mn,mx,nm)))

subplot(3,1,2)
plot(squeeze(binsRes1(2,:,1)),'b'); hold on;
plot(squeeze(binsRes1(2,:,2)),'r'); 
plot(squeeze(binsRes2(2,:,1)),':b'); hold on;
plot(squeeze(binsRes2(2,:,2)),':r'); 
ylim([0 ymax]);
set(gca,'XTick',linspace(0,50,nm))
set(gca,'XTickLabel',round(linspace(mn,mx,nm)))

subplot(3,1,3)
plot(squeeze(binsRes1(3,:,1)),'b'); hold on;
plot(squeeze(binsRes1(3,:,2)),'r'); 
plot(squeeze(binsRes2(3,:,1)),':b'); hold on;
plot(squeeze(binsRes2(3,:,2)),':r'); 
ylim([0 ymax]);
set(gca,'XTick',linspace(0,50,nm))
set(gca,'XTickLabel',round(linspace(mn,mx,nm)))



