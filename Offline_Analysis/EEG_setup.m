function [components, char_freq, EEG_intfreq, state] = EEG_setup(subj,data_type)
%% EEG_setup.m
% Matthew McCann

% This function is similar in nature to the script EEG_only_TrainSet.m. It
% acts to prepare preprocessed EEG data into a features matrix that will be
% combined with a NIRS features matrix within the script EEG_NIRS_learn.m.
% This function takes the tEEG data (except channel FC2) from the first 
% five training sessions for a given subject, snd breaks the data down into
% matrix where columns represent a channel during a certain imagery state. 

% NOTE: The output of the components matrix must change based on subject.
% Eliminating bad channels increases classification accuracy. Go to lines 
% 83-93 for subject-dependent changes. At present time, the channels FC1 
% and FC2 are not used. They can be incorporated if necessary.

% Last Updated: 27 July, 2015
% Changelog
%   27/7/2015: Included LH imagery for subject SC. 
%   22/07/2015: Added ability to load both training and test data.
%   21/07/2015: Added logic to accomodate characteristic ferquencies for
%   EEG data 

%% Load all datasets for one subject
type = input('EEG or tEEG signals? ','s');

if strcmp(data_type,'train')
disp('Choose files to load for training.')
[~, sig1, state] = load_EEG('clean',subj); %Load first file
[~, sig2, ~]     = load_EEG('clean',subj);
[~, sig3, ~]     = load_EEG('clean',subj);
[~, sig4, ~]     = load_EEG('clean',subj);
[~, sig5, ~]     = load_EEG('clean',subj);

%% Signals matrix decomposition

    % Combine signals matrices into one big matrix
    allChannels = [sig1; sig2; sig3; sig4; sig5];
    clearvars sig*    

    % Seperate states into targets and elongate state variable
    % We want to create a single long column of the state variable in 
    % order to combine all trials
    state = [state'; 
             state'; 
             state'; 
             state'; 
             state'];
         
elseif strcmp(data_type, 'test')
    [~, sig1, state] = load_EEG('clean',subj); %Load first file
    state = state';
    allChannels = sig1;
    clearvars sig* 
end

    % Isolate resting state data and remove baseline
    rest = find(state == 0);
    restData = allChannels(rest,:);
    restData = mean(restData);
    allChannels = bsxfun(@minus,allChannels,restData);
    
    % Define states as motor imagery
    left  = find(state == 1);
    right = find(state == 2);
    hands = find(state == 3);
    feet  = find(state == 4);
    
    % Isolate signal data by state
    LH_C2  = allChannels(left,4); 
    LH_C4  = allChannels(left,5);
    RH_C3  = allChannels(right,1);
    RH_C1  = allChannels(right,2);
    BH_C2  = allChannels(hands,4); 
    BH_C4  = allChannels(hands,5);
    BH_C3  = allChannels(hands,1);
    BH_C1  = allChannels(hands,2);    
    F_Cz   = allChannels(feet,3);
    F_FCz  = allChannels(feet,7);
    
    % Create component matrix for easier evaluation
    % NOTE: must add more subjects 
    switch subj
        case 'MRA'
            % Channels C2, C4, and FC2 eliminated
            components  = [RH_C3,RH_C1,BH_C2,BH_C4,BH_C3,BH_C1,F_Cz,F_FCz]; 
        case 'JK'
            components  = [RH_C3,RH_C1,BH_C2,BH_C4,BH_C3,BH_C1,F_Cz,F_FCz];
        case 'NC'
            components  = [RH_C3,RH_C1,BH_C2,BH_C4,BH_C3,BH_C1,F_Cz,F_FCz];
        case 'SC'
            components  = [LH_C2,LH_C4,RH_C3,RH_C1,BH_C2,BH_C4,BH_C3,BH_C1,F_Cz,F_FCz];
    end
     
    % Here for convenience when eliminating imagery states
    % LH_C2,LH_C4,LH_FC2
    % RH_C3,RH_C1,RH_FC1,
    % BH_C2,BH_C4,BH_FC2,BH_C3,BH_C1,BH_FC1,
    
%% Interesting Frequency Range for each channel and classifier
% Based on data gathered through OfflineAnalysis.m in BCI2000. The format
% of this matrix follows to order of the channels given in the above
% section. The frequency ranges given are in Hz, and span the
% characteristic frequency +/- user-specified bounds in Hz.

% Note: channels must be eliminated manually based on subject.

switch subj
    case 'MRA'
        if strcmp(type,'tEEG')
            char_freq = single([%20;   % C2_left 
                                %15;   % C4_left 
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
            char_freq = single([%11;    % C2_left 
                                %25;    % C4_left 
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
            char_freq = single([%11;   % C2_left 
                                %13;   % C4_left 
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
            char_freq = single([%11;    % C2_left 
                                %11;    % C4_left 
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
            char_freq = single([%7;    % C2_left 
                                %11;   % C4_left 
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
            char_freq = single([%9;     % C2_left 
                                %9;     % C4_left 
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
            char_freq = single([31;    % C2_left 
                                15;    % C4_left 
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
                                13]); % FCz_feet 
        elseif strcmp(type, 'EEG')
            char_freq = single([15;     % C2_left 
                                23;     % C4_left 
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
                                15]);  % FCz_feet  
        end          
end

bounds = 2;
EEG_intfreq = zeros(length(char_freq),(2.*bounds+1));
for f = 1:length(char_freq)
    EEG_intfreq(f,:) = (char_freq(f)-bounds):(char_freq(f)+bounds);
end
    EEG_intfreq = single(EEG_intfreq);
end
