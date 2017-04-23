function startPos = ServoCenter(finger, pins)
%% Servo Centering 
% This program sets all servomotors to their zeroed state with a pulse 
% width of 1500. After centering, the fingers can be pretensed by changing
% the position of the servos in multiples of the minimum increment (PW =
% 15).

% Author: Matthew McCann
% 02/6/2015

% Last Updated: 20 July, 2015
%% Centering
global S servoInc
fprintf(S, strcat('#',num2str(pins(1)),'P1500 T500','#',num2str(pins(2)),'P1500 T500',...
    '#',num2str(pins(3)),'P1500 T500','#',num2str(pins(4)),'P1500 T500'));

adjust = input('Input array with offset for [flex, DIP, PIP, MCP]. Must be multiples of min. increment. ');
adjust = adjust.*servoInc;
if strcmp(finger,'ring')
    adjust = -1.*adjust;
end
off = ones(1,4).*1500 + adjust;

fprintf(S, strcat('#',num2str(pins(1)),'P',num2str(off(1)),'T500','#',num2str(pins(2)),'P',num2str(off(2)),'T500',...
    '#',num2str(pins(3)),'P',num2str(off(3)),'T500','#',num2str(pins(4)),'P',num2str(off(4)),'T500'))

ask = input('Is more adjustment necessary (y,n)? ', 's');

if ask == 'y'
    tune = input('Enter fine tuning parameters. ');
    if strcmp(finger,'ring')
        tune = -1.*tune;
    end
    tune = off+tune;
    fprintf(S, strcat('#',num2str(pins(1)),'P',num2str(tune(1)),'T500','#',num2str(pins(2)),'P',num2str(tune(2)),...
    '#',num2str(pins(3)),'P',num2str(tune(3)),'#',num2str(pins(4)),'P',num2str(tune(4))));
    startPos = tune;
    ask = input('Is more adjustment necessary (y,n)? ', 's');
else
    startPos = off;
end

end