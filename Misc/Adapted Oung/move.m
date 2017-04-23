function turn = move(finger, start, motorPWM)
%% Move.m 
% Turns the servomotors for the specified finger by the amount defined by 
% motorPWM. Note that the format for input must be [flex, dip, pip, mcp].

global S

fprintf(S, strcat('#',finger(1),'P',start+motorPWM(1),'#',finger(2),'P',start+motorPWM(2),...
    '#',finger(3),'P',start+motorPWM(3),'#',finger(4),'P',start+motorPWM(4)));

end