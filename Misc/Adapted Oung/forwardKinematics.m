function xyz =  forwardKinematics(jointAng)
%% fowardKinematics.m
% Adapted from the Arduino code written by Stephen Oung. This function 
% calculates the x, y, and z coordinates within the joint space when given
% the angles of the joints for a given finger. Joint angles must be given
% in radians.

disp('Inside forwardKinematics.m');

global a toDeg j1LimRad j2LimRad j3LimRad j4LimRad

xyz = zeros(1,3);

if(jointAng(1) < j1LimRad(1) || jointAng(1) > j1LimRad(2) || jointAng(2) < j2LimRad(1) || jointAng(2) > j2LimRad(2) || ...
     jointAng(3) < j3LimRad(1) || jointAng(3) > j3LimRad(2) || jointAng(4) < j4LimRad(1) || jointAng(4) > j4LimRad(2))
       
   disp('Outside Joint Limits');
   disp(jointAng(1)*toDeg);
   disp(jointAng(2)*toDeg);
   disp(jointAng(3)*toDeg);
   disp(jointAng(4)*toDeg);
  
else  
  xyz(1) = (cos(jointAng(1))*cos(jointAng(2))*cos(jointAng(3))+cos(jointAng(1))*-sin(jointAng(2))*sin(jointAng(3)))*a(4)*cos(jointAng(4)) + ...
    (cos(jointAng(1))*cos(jointAng(2))*-sin(jointAng(3))+cos(jointAng(1))*-sin(jointAng(2))*cos(jointAng(3)))*a(4)*sin(jointAng(4)) + ... 
    (cos(jointAng(1))*cos(jointAng(2))*a(3)*cos(jointAng(3))+cos(jointAng(1))*-sin(jointAng(2))*a(3)*sin(jointAng(3))+cos(jointAng(1))*a(2)*cos(jointAng(2))+a(1)*cos(jointAng(1)));
  
  xyz(2) = (sin(jointAng(1))*cos(jointAng(2))*cos(jointAng(3))+sin(jointAng(1))*-sin(jointAng(2))*sin(jointAng(3)))*a(4)*cos(jointAng(4)) + ...
    (sin(jointAng(1))*cos(jointAng(2))*-sin(jointAng(3))+sin(jointAng(1))*-sin(jointAng(2))*cos(jointAng(3)))*a(4)*sin(jointAng(4)) + ...
    (sin(jointAng(1))*cos(jointAng(2))*a(3)*cos(jointAng(3))+sin(jointAng(1))*-sin(jointAng(2))*a(3)*sin(jointAng(3))+sin(jointAng(1))*a(2)*cos(jointAng(2))+a(1)*sin(jointAng(1)));
  
  xyz(3) = (sin(jointAng(2))*cos(jointAng(3))+cos(jointAng(2))*sin(jointAng(3)))*a(4)*cos(jointAng(4)) + ...
    (sin(jointAng(2))*-sin(jointAng(3))+cos(jointAng(2))*cos(jointAng(3)))*a(4)*sin(jointAng(4)) + ...
    sin(jointAng(2))*a(3)*cos(jointAng(3))+cos(jointAng(2))*a(3)*sin(jointAng(3))+a(2)*sin(jointAng(3)); 
end