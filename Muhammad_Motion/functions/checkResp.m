function correctTrial = checkResp(resp, targetAngle)
global params;
correctTrial = NaN;

angleIdx = find(targetAngle == params.stim.possibleAngels);
up_downCorrect = params.stim.cw_ccw(angleIdx);

respIdx = find(resp.key == params.responseVar.allowedRespKeysCodes);
up_downAns = params.responseVar.cw_ccw(respIdx);

if up_downCorrect == up_downAns
    correctTrial = 1;
else
    correctTrial = 0;
end
