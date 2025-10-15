figure;
for b = 1:params.blockVars.numBlocks
    subplot(1,2,b); 

    plot(expData.stairs{b,1}.strength); hold on;
    plot(expData.stairs{b,2}.strength,'r'); hold on;
    plot(expData.stairs{b,3}.strength,'g'); hold on;
    title(sprintf('block number %d',b));
    
%     expData.stairs{b,1}.threshold
%     expData.stairs{b,2}.threshold
%     expData.stairs{b,3}.threshold
    meansBlock(b) = nanmean([expData.stairs{b,1}.threshold, expData.stairs{b,2}.threshold,  expData.stairs{b,3}.threshold]);

end

Threshold2use = meansBlock(2)