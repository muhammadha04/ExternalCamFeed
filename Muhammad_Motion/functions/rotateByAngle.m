function [posR] = rotateByAngle(pos, angle)

% pos is a n*2 matrix with x and y positions
% angle is a column(!!!) vector of rotation angles (in radians)

if size(pos,2)~=2
  error('input should be Nx2')
end

[posTh, posRad] = cart2pol(pos(:,1), pos(:,2));

[posR(:,1), posR(:,2)] = pol2cart(posTh + angle, posRad);


% if 0
%   % test code, copy and paste into Matlab
%   pos = rand(5,2);
%    [posR]= rotateByAngle(pos, angle);
%   figure; hold on; plot(pos(:,1), pos(:,2), 'bo'); 
%   plot(posR(:,1), posR(:,2), 'r+'); 
%   axis equal
%   grid on,
% end
% 
