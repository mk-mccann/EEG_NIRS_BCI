%% Middle Control - Forward Kinematics
% Author: Matthew McCann
% 01/6/2015

% Controls the forward kinematics for full flexion of the middle finger
% Note that manual adjustment will be needed to ensure the correct
% tension of the tendons. This can be accomplished simply by running the
% script BasicServoControl.m to set the motors  to a zeroed
% position, then adjusting individual tensions.

% Pin definitions: 8 = Flex, 11 = DIP, 12 = PIP, 15 = MCP 

%%Establish connection with SSC-32
% clc; 
% S = serial('COM6');
% set(S, 'Terminator', 'CR/LF');
% set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
% fopen(S);

%% Flexion

%Give slack to Flex, DIP, and PIP
fprintf(S, '#8 P1650 T250 #11 P1520 T500 #12  P1520 T500'); 

fprintf(S, '#8 P1670 T250')
pause
fprintf(S, '#15 P1325 T300')
pause
fprintf(S, '#12 P1425 T500')
pause
fprintf(S, '#11 P1500 T500')
pause
fprintf(S, '#8 P1700 T250')
pause
fprintf(S, '#15 P1300 T300')
pause
disp('end')


% fclose(S);