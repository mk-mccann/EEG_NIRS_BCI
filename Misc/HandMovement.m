%% HandMovement.m
% Matthew McCann 
% Last Udpdated: 20 July, 2015

% This script acts to test the movement of the artificial hand. It does not
% process any EEG or NIRS data.

clc;
%% Establish Hand Variables
global servoInc
servoInc = 15;  %minimum servo increment

% Define Joints
    % Pinky
    % Pflex = '0'; Pdip = '3'; Ppip = '4'; Pmcp = '7';
    pinky = [0, 3, 4, 7];
    % Ring
    % Rflex = '16'; Rdip = '19'; Rpip = '20'; Rmcp = '23';
    ring = [16, 19, 20, 23];
    % Middle
    %Mflex = '8'; Mdip = '11'; Mpip = '12'; Mmcp = '15';
    middle = [8, 11, 12, 15];

%% Setup Serial Connection
global S
S = serial('COM6');
set(S, 'Terminator', 'CR/LF');
set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
fopen(S);

%% Center and Adjust Servos
disp('Center and adjust pinky.')
startPosPinky = ServoCenter('pinky',pinky); %extract beginning motor positions
disp('Center and adjust ring finger.')
startPosRing = ServoCenter('ring',ring); %extract beginning motor positions
disp('Center and adjust middle finger.')
startPosMid = ServoCenter('middle',middle); %extract beginning motor positions

%% Move Hand
for i = 1:5
    close_middle;
    pause(0.3);
    open_finger(1);
    close_ring;
    pause(0.3);
    open_finger(2);
    close_pinky;
    pause(0.3);
    open_finger(3);
end
%% Close Serial Connection
fclose(S);
