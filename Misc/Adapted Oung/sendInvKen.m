function pwm = sendInvKen(finger, startPos, xyz)
global jointTerms toDeg

jointAng = zeros(1, jointTerms);
length = zeros(1,jointTerms);
pwm = zeros(1,jointTerms);

jointAng = inverseKinematics(xyz);
    disp(jointAng(1).*toDeg);
    disp(jointAng(2).*toDeg);
    disp(jointAng(3).*toDeg);
    disp(jointAng(4).*toDeg);
    
length = elongEq(jointAng);

for i = 1:1:jointTerms
    pwm(i) = lengthToPWM(length(i));
end
move(finger,startPos,pwm);
end