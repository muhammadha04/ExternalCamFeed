function [allPosPix dircs ]= computeMotion_inSquare_BM(trialAngle,dotCoh)
global params; 

%Initial random dot position
% randAnglesRad = pi*2*(rand(params.dots.num,1)); randAmps = sqrt(params.stim.radiusDeg*(rand(params.dots.num,1)));
% [allPos.x,allPos.y] = pol2cart(randAnglesRad,randAmps);
q = rand(params.dots.num,1)*pi*2; 
r = (rand(params.dots.num,1)).^0.5;
allPos.x = r.*params.stim.radiusDeg.*cos(q);
allPos.y = r.*params.stim.radiusDeg.*sin(q);

% Compute motion direction for coherent motion
dxdy = zeros(params.dots.num,2); 
dxdy_dirc 	= repmat(params.stim.speedDegPerMsec * (1000/params.screenVar.monRefresh) * [cos(pi*trialAngle/180.0) sin(pi*trialAngle/180.0)], params.dots.num,1);

%Compute motion according to direction, wrap if necessary and randomly
%re-assign postions if limited lifetime for dots
for i = 2:params.stim.durInFrames
    % Compute motion direction for NON coherent motion (random directions)
    randDirc = randi(360,params.dots.num,1);
    randDirc = deg2rad(randDirc);
    dxdy_rand 	= (params.stim.speedDegPerMsec * (1000/params.screenVar.monRefresh) * [cos(randDirc) sin(randDirc)]);
    
    % Calculate which dots will be moving coherently to direction trial angle
    % and which not
    L = rand(params.dots.num,1) < dotCoh;
    dxdy(L,:) = dxdy_dirc(L,:);
    if sum(~L) > 0, 
        dxdy(~L,:) = dxdy_rand(~L,:); 
    end
    dircs(i,:) = repmat(deg2rad(trialAngle),params.dots.num,1);
    dircs(i,~L) = randDirc(~L);
    
    allPos.x(:,i) = allPos.x(:,i-1)+dxdy(:,1);
    allPos.y(:,i) = allPos.y(:,i-1)+dxdy(:,2);
    
    [th(:,i) rho(:,i)] = cart2pol(allPos.x(:,i),allPos.y(:,i));
    wrap = rho(:,i) > params.stim.radiusDeg; %wrap = abs(allPos.x(:,i))> params.stim.radiusDeg | abs(allPos.y(:,i))>params.stim.radiusDeg; 
    
    if sum(wrap)>0
        alpha = atan(allPos.y(wrap,i)./allPos.x(wrap,i));
        f = allPos.x(wrap,i)<0; 
        if sum(f)>0
            alpha(f) = pi+alpha(f);
        end
        beta = pi-2*(alpha-dircs(i,wrap)');
        newAngs = mod((alpha+beta),2*pi);
        [x y] = pol2cart(newAngs,params.stim.radiusDeg);
        allPos.x(wrap,i) = x; %-allPos.x(wrap,i);
        allPos.y(wrap,i) = y;% -allPos.y(wrap,i);
    end  
    if params.stim.lifetime
        jump = rand(params.dots.num,1)<params.stim.limitLifetime;
        if sum(jump)>0
            q = rand(sum(jump),1)*pi*2; 
            r = (rand(sum(jump),1)).^0.5;
            allPos.x(jump,i) = r.*params.stim.radiusDeg.*cos(q);
            allPos.y(jump,i) = r.*params.stim.radiusDeg.*sin(q);
        end
    end
end
%Transform to pixels from visual degrees
allPosPix.x = floor(params.screenVar.ppd .* allPos.x)+ params.screenVar.centerPix(1); 
allPosPix.y = floor(params.screenVar.ppd .* allPos.y)+ params.screenVar.centerPix(2);	