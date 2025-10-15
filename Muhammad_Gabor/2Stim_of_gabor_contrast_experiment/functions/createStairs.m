function  [stair dotCoh] = createStairs(stairOrder,dotCoh)
global params;

for i = 1: params.stair.numStaircases
    stair{i} = upDownStaircase(1,params.stair.numDownStep(i), params.stair.startValues(i),params.stair.startStepsize(i), 'levitt');
    stair{i}.minThreshold = params.stair.minThresh;
    stair{i}.maxThreshold = params.stair.maxThresh;
    stair{i}.minStepsize  = params.stair.minStepsize;
end
u = unique(stairOrder);
for i=1:length(u)
    fidx = find(stairOrder==u(i));
    idx = fidx(1);
    dotCoh(idx) = params.stair.startValues(i);
end
