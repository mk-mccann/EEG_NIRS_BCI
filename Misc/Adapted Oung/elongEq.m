function elongation = elongEq(jointAng)
%% elongEq.m
% Adaptation of the elongationEquation.ino function by Stephen Oung.
% Requires joint angles in radians.

global t r lFix a 
elongation = zeros(1,4);

elongation(1) = sqrt( (lFix(2)*cos(jointAng(2)) + t(2)*cos(pi/2 - jointAng(2)) + lFix(1)).^2 + ...
    (lFix(2)*sin(jointAng(2)) - t(2)*cos(-jointAng(2)) - t(1)).^2) -...
    sqrt( (2*t(2)).^2 + (lFix(2) + lFix(1)).^2);

elongation(2) = r(1)*jointAng(2) - ((a(1) + lFix(3)) - sqrt(  (t(1) + lFix(3)*sin(jointAng(3)) - t(3)*cos(jointAng(3))).^2  + ...
    (lFix(3)*cos(jointAng(3)) + t(3)*sin(-jointAng(3)) + a(1)).^2));
    
elongation(3) = r(1)*jointAng(2) + r(2)*jointAng(3) - ((a(2) + lFix(4)) - sqrt( (t(3) + lFix(4)*sin(jointAng(4)) - t(4)*cos(jointAng(4))).^2 + ... 
    (lFix(4)*cos(jointAng(4)) + t(4)*sin(-jointAng(4)) + a(2)).^2) );

elongation(4) = r(1)*jointAng(2) + r(2)*jointAng(3) + r(3)*jointAng(4);

end

