function [] = open_finger(state)
%% openfinger.m
% Matthew McCann - 16/07/2015

% Last Updated: 20 July, 2015

% Opens the desired finger with an input of 1, 2, or 3 (middle, ring,
% pinky, respectively).

global S

% Define Joints
    % Pinky
    % Pflex = '0'; Pdip = '3'; Ppip = '4'; Pmcp = '7';
    pinky = [0, 3, 4, 7];
    % Ring
    % Rflex = '16'; Rdip = '19'; Rpip = '20'; Rmcp = '23';
    ring = [16, 19, 20, 23];
    % Middle
    % Mflex = '8'; Mdip = '11'; Mpip = '12'; Mmcp = '15';
    middle = [8, 11, 12, 15];

if state == 1
    finger = middle;
elseif state == 2
    finger = ring;
elseif state == 3
    finger = pinky;
end

fprintf(S, strcat('#',num2str(finger(1)),'P1500 #',num2str(finger(2)),'P1500 #',num2str(finger(3)),'P1500 #',num2str(finger(4)),'P1500'));

end

