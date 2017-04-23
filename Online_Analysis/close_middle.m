function [] = close_middle()
%% closemiddle.m
% Matthew McCann
% July 17, 2015

% Last Updated: 20 July, 2015

% Controls movement of middle finger to full flexion. The values used to
% move the fingers were determined manually. 

% Pin definitions: 8 = Flex, 11 = DIP, 12 = PIP, 15 = MCP 

% Establish connection with serial port
global S
% S = serial('COM6');
% set(S, 'Terminator', 'CR/LF');
% set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
% fopen(S);

%Give slack to Flex, DIP, and PIP
fprintf(S, '#8 P1650 #11 P1575 T150 #12 P1520 T150'); 

fprintf(S, '#15 P1300');  % Contract MCP
fprintf(S, '#15 P1330');  % Give slight slack to MCP
fprintf(S, '#12 P1410');  % Contract PIP
fprintf(S,' #11 P1600');

% pause(0.25)
% fprintf(S, '#8 P1500  #11 P1500  #12 P1500  #15 P1500 '); 
% fclose(S);
end
