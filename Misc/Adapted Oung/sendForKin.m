function pwm = sendForKin(finger, startPos, jointAngles)
%% SendForKim.m
% Adapted from Stephen Oung's Arduino code. Takes finger of interest and
% it's starting position to calculate forward kinematics, necessary change
% in length, and execute the finger movement. 

global jointTerms xyzTerms toRad

for i = 1:jointTerms;
    jointAngles(i) = jointAngles(i).*toRad;
end

xyz = zeros(1,xyzTerms);
pwm = zeros(1,jointTerms);
length = zeros(1,jointTerms);

xyz = forwardKinematics(jointAngles);
if xyz(1) ~= 0
    length = elongEq(jointAngles);
    
    for j = 1:1:jointTerms
        pwm(j) = lengthToPWM(length(j));
    end
    
end

move(finger, startPos, pwm);
end