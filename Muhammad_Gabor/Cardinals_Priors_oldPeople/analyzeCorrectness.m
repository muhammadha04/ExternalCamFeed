allBlocks = struct('correct',{[]}, 'angle',{[]});

allBlocks.correct = [allBlocks.correct; respDisc.correct']; allBlocks.angle = [allBlocks.angle ;[expData.Angels]];

angles = [3 357]; 
%angles = [3 357 183 177];

for ang = 1:length(angles)
    f = find(allBlocks.angle == angles(ang));
    corr(ang) = sum(allBlocks.correct(f))/length(allBlocks.correct(f));
end
