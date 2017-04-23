function [] = it_moves(classified)
%% it_moves.m
% Matthew McCann - 16/07/2015

% Last Updated: 20 July, 2015

% Reads classification matrix, determines which state column a binary classifier
% occurs in (RH, BH, F). If a state is true for one imagery modality only,
% the hand will move accordingly. If there is no classification for a given
% observation, the hand opens. If there are conflicting classifications,
% nothing occurs. 

% Right hand imagery = move middle finger (state = 1)
% Both hands imagery = move ring finger (state = 2)
% Feet imagery = move pinky finger (state = 3)

%% Open Serial Connection
% global S
% S = serial('COM6');
% set(S, 'Terminator', 'CR/LF');
% set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
% fopen(S);

% Initial variable
[r,c] = size(classified);

% Initially set old state equal to three
oldState = 3;

for m = 1:r
        % Find which motor imagery states have been classified
        obsv = classified(m,:);
        column = find(obsv == 1);
        num_class = numel(column);

        %% Movement control
        % If at rest --------------------------------------------------------------
        if num_class == 0
            % open fingers
            open_finger(oldState); % Open the last closed finger
            pause(0.2)

        % If in distinct imagery state -------------------------------------------- 
        elseif num_class == 1
            % Find new state
            if column == 1 % Right hand imagery
                state = 1;
            elseif column == 2 % Both hands imagery
                state = 2;
            elseif column == 3 % Feet imagery
                state = 3;
            end

            % Check if same as old state
            if state == oldState % If same as old state
                % Do nothing
                pause(0.05);
            else                 % If state has changed
                % Open most recently closed finger
                open_finger(oldState);
                pause(0.2);
                
                %Check state
                if state == 1       % Right hand imagery
                    close_middle;
                    pause(0.2);
                elseif state == 2   % Both hands imagery 
                    close_ring;
                    pause(0.2);
                elseif state == 3   % Both feet imagery
                    close_pinky;
                    pause(0.2);
                end

            end

            % Save state
            oldState = state;

        % If conflicting imagery states -------------------------------------------
        elseif num_class > 1
        % do nothing

        end
end
% Reopen all fingers when loop is done
open_finger(1);
open_finger(2);
open_finger(3);

% fclose(S);