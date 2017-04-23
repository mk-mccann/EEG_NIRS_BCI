function [intfreq,char_freq] = get_EEG_char_freqs(type)
%% get_EEG_char_freqs.m
% Matthew McCann
% 27 July, 2015

% Based on subject and EEG type (tEEG or EEG), load characteristic
% frequencies into script workspace. Channel elimination for
% characteristic frequencies is done here.

% Last Updated: 27 July, 2015
% Changelog
%   27/7/2015: Only FC channels are eliminated. No LH elimination for any
%   subject.

global subj

switch subj
    case 'MRA'
        if strcmp(type,'tEEG')
            char_freq = single([20;   % C2_left 
                                15;   % C4_left 
                                %15;   % FC2_left
                                25;   % C3_right 
                                25;   % C1_right 
                                %17;   % FC1_right
                                13;   % C2_both
                                15;   % C4_both
                                %13;   % FC2_both
                                15;   % C3_both
                                19;   % C1_both
                                %27;   % FC1_both
                                23;   % Cz_feet 
                                17]); % FCz_feet
        elseif strcmp(type, 'EEG')
            char_freq = single([11;    % C2_left 
                                25;    % C4_left 
                                %17;    % FC2_left
                                29;    % C3_right 
                                23;    % C1_right 
                                %27;    % FC1_right
                                15;    % C2_both
                                25;    % C4_both
                                %19;    % FC2_both
                                15;    % C3_both
                                15;    % C1_both
                                %15;    % FC1_both
                                29;    % Cz_feet 
                                23]);  % FCz_feet            
        end
    case 'JK'
        if strcmp(type,'tEEG')
            char_freq = single([11;   % C2_left 
                                13;   % C4_left 
                                %19;   % FC2_left
                                31;    % C3_right 
                                31;   % C1_right
                                %27;   % FC1_right
                                13;   % C2_both
                                11;   % C4_both
                                %23;   % FC2_both
                                23;   % C3_both
                                23;   % C1_both
                                %11;   % FC1_both
                                13;   % Cz_feet
                                21]); % FCz_feet  
        elseif strcmp(type, 'EEG')
            char_freq = single([11;    % C2_left 
                                11;    % C4_left 
                                %11;    % FC2_left
                                11;    % C3_right 
                                11;    % C1_right 
                                %9;     % FC1_right
                                11;    % C2_both
                                21;    % C4_both
                                %11;    % FC2_both
                                13;     % C3_both
                                11;    % C1_both
                                %10;    % FC1_both
                                11;    % Cz_feet 
                                11]);  % FCz_feet            
        end                        
                        
    case 'NC'
        if strcmp(type,'tEEG')
            char_freq = single([7;    % C2_left 
                                11;   % C4_left 
                                %9;    % FC2_left
                                9;    % C3_right 
                                9;    % C1_right 
                                %7;    % FC1_right
                                8;    % C2_both
                                8;    % C4_both
                                %25;   % FC2_both
                                9;    % C3_both
                                19;   % C1_both  
                                %9;    % FC1_both
                                9;    % Cz_feet
                                11]); % FCz_feet 
        elseif strcmp(type, 'EEG')
            char_freq = single([9;     % C2_left 
                                9;     % C4_left 
                                %9;     % FC2_left
                                9;     % C3_right 
                                9;     % C1_right 
                                %9;     % FC1_right
                                13;    % C2_both
                                11;    % C4_both
                                %25;    % FC2_both
                                15;    % C3_both
                                19;    % C1_both
                                %9;     % FC1_both
                                9;     % Cz_feet 
                                11]);  % FCz_feet  
        end    
        
    case 'SC'
        if strcmp(type,'tEEG')
            char_freq = single([%31;    % C2_left 
                                %15;    % C4_left 
                                %29;    % FC2_left
                                9;    % C3_right 
                                13;   % C1_right 
                                %25;    % FC1_right
                                29;   % C2_both
                                29;   % C4_both
                                %25;    % FC2_both
                                19;   % C3_both
                                27;   % C1_both  
                                %29;    % FC1_both
                                21;   % Cz_feet
                                13    % FCz_feet
                                ]);  
        elseif strcmp(type, 'EEG')
            char_freq = single([%15;     % C2_left 
                                %23;     % C4_left 
                                %25;     % FC2_left
                                31;    % C3_right 
                                27;    % C1_right 
                                %31;     % FC1_right
                                15;    % C2_both
                                17;    % C4_both
                                %29;     % FC2_both
                                31;    % C3_both
                                31;    % C1_both
                                %31;     % FC1_both
                                15;    % Cz_feet 
                                15     % FCz_feet
                                ]);  
        end          
end

bounds = 2;
intfreq = zeros(length(char_freq),(2.*bounds+1));
for f = 1:length(char_freq)
    intfreq(f,:) = (char_freq(f)-bounds):(char_freq(f)+bounds);
end

end

