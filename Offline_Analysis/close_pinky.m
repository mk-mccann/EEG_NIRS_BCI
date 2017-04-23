function [] = close_pinky()
%% closepinky.m
% Matthew McCann
% July 17, 2015

% Controls movement of pinky finger to full flexion. The values used to
% move the fingers were determined manually. 

% Last Updated: 20 July, 2015

% *************************************************************************
% Pin definitions: 0 = Flex, 3 = DIP, 4 = PIP, 7 = MCP 

% Establish connection with serial port
global S
% S = serial('COM6');
% set(S, 'Terminator', 'CR/LF');
% set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
% fopen(S);

%Give slack to Flex, DIP, and PIP
fprintf(S, '#0 P1675 #3 P1600 T150 #4 P1520 T150'); 

fprintf(S, '#7 P1300'); % Contract MCP 
fprintf(S, '#7 P1330'); % Give slight slack to MCP
fprintf(S, '#4 P1425'); % Contract PIP
fprintf(S, '#0 P1725'); % Give slight slack to Flex


% pause(0.25)
% fprintf(S, '#0 P1500 #3 P1500 #4 P1500 #7 P1500');
% fclose(S);

end

