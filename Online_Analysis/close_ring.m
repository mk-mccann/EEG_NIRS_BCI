function [] = close_ring()
%% closering.m
% Matthew McCann
% July 17, 2015

% Last Updated: 20 July, 2015

% Controls movement of ring finger to full flexion. The values used to
% move the fingers were determined manually. 
% Note that servos must turn opposite direction of pinky and middle finger,
% so tightening values are > 1500, and loosening values are < 1500.

% Pin definitions: 16 = Flex, 19 = DIP, 20 = PIP, 23 = MCP 

% Establish connection with serial port
global S
% S = serial('COM6');
% set(S, 'Terminator', 'CR/LF');
% set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
% fopen(S);

%Give slack to Flex, DIP, and PIP
fprintf(S, '#16 P1325 #19 P1400 T150 #20 P1450 T150'); 

fprintf(S, '#23 P1700'); % Contract MCP
fprintf(S, '#23 P1670'); % Give slight slack to MCP
fprintf(S, '#20 P1575'); % Contract PIP
fprintf(S, '#16 P1275'); % Give slack to Flex
fprintf(S, '#19 P1425'); % Slightly contract DIP
% fclose(S);
end
