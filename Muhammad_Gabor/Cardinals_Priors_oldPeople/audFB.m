function audFB(correctTrial)
global params;

if correctTrial
    if params.fbVars.positiveFeedback
        beep2(params.fbVars.high,params.fbVars.dur)
    end
else
    if params.fbVars.negativeFeedback
        beep2(params.fbVars.low,params.fbVars.dur)
    end
end
