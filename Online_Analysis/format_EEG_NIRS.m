function [tEEG_components, NIRS_components,EEG_components] = format_EEG_NIRS(tEEG_data, NIRS_data, EEG_opt)
% Matthew McCann
% 28 July, 2015

% Formats tEEG and NIRS (and optional EEG) data into the correct format
% for feature extraction. This allows for matching between tEEG and NIRS 
% data before feature extraction. Channel and imagery elimination occurs
% within this script. 

% To eliminate channels from tEEG or EEG data, simply remove the channels 
% from the components matrices for these modalities. Imagery states are 
% removed in a similar manner.

% To eliminate channels from NIRS data, simply remove channels from the
% RH_C3, F_Cz, LH_C4 variables inder each subject in the NIRS section. To
% remove imagery states, simply remove imagery variables in the
% NIRS_components section under each subject. 

% When eliminating channels and/or imagery states, be sure to eliminate the
% same channels/imagery states from the offline classifier, remove the
% correct channels from the get_EEG_char_freqs.m function.

% Last Updated: 28/7/2015
% Changelog

% EEG DATA FORMAT - columns are electrodes with known locations
%       [C3 C1 Cz C2 C4 FC1 FCz FC2]

% NIRS DATA FORMAT - columns are NIRS channels
%       [1 2 3 4 5 .... 18 19 20]

%% Global Variables
global subj

if nargin == 2
    %% tEEG Formatting ---------------------------------------------------------
        % Isolate signal data by state
        tEEG_LH_C2  = tEEG_data(:,4); 
        tEEG_LH_C4  = tEEG_data(:,5);
        tEEG_RH_C3  = tEEG_data(:,1);
        tEEG_RH_C1  = tEEG_data(:,2);
        tEEG_BH_C2  = tEEG_data(:,4); 
        tEEG_BH_C4  = tEEG_data(:,5);
        tEEG_BH_C3  = tEEG_data(:,1);
        tEEG_BH_C1  = tEEG_data(:,2);    
        tEEG_F_Cz   = tEEG_data(:,3);
        tEEG_F_FCz  = tEEG_data(:,7);

        % This section has the ability to eliminate channels
        switch subj
            case 'MRA'
                % Channels C2, C4, and FC2 eliminated
                tEEG_components  = [tEEG_RH_C3,tEEG_RH_C1,tEEG_BH_C2,tEEG_BH_C4,tEEG_BH_C3,tEEG_BH_C1,tEEG_F_Cz,tEEG_F_FCz]; 
            case 'JK'
                % Channels C2, C4, and FC2 eliminated            
                tEEG_components  = [tEEG_RH_C3,tEEG_RH_C1,tEEG_BH_C2,tEEG_BH_C4,tEEG_BH_C3,tEEG_BH_C1,tEEG_F_Cz,tEEG_F_FCz];
            case 'NC'
                % Channels C2, C4, and FC2 eliminated            
                tEEG_components  = [tEEG_RH_C3,tEEG_RH_C1,tEEG_BH_C2,tEEG_BH_C4,tEEG_BH_C3,tEEG_BH_C1,tEEG_F_Cz,tEEG_F_FCz];
            case 'SC'
                % All channels present            
                tEEG_components  = [tEEG_LH_C2,tEEG_LH_C4,tEEG_RH_C3,tEEG_RH_C1,tEEG_BH_C2,tEEG_BH_C4,tEEG_BH_C3,tEEG_BH_C1];
        end    
        
        % For removing imagery states
        % tEEG_LH_C2,tEEG_LH_C4,
        % tEEG_F_Cz,tEEG_F_FCz
        % tEEG_BH_C2,tEEG_BH_C4,tEEG_BH_C3,tEEG_BH_C1,

    %% NIRS Formatting --------------------------------------------------------
    clearvars LH* RH* F*
    
    % Break into relevant channels
    switch subj
        case 'MRA' %-----------------------------------------------------------
            % Dataset 001 -----------------------------------------------------
                [RH_1, LH_1, F_1, ~] = nirx_channels(NIRS_data);            

                % C3_RH
                    RH_C3 = RH_1(:,[2,4]); % Reject channels C5, C9
                % Cz_F
                    F_Cz = [mean(F_1(:,1:2),2), F_1(:,4)]; % Reject channel C11     
                % C4_LH
                    LH_C4 = [LH_1(:,4), LH_1(:,4)]; % Reject channels C15, C16, C19 
                                                            % Max 2 channels for all MRA datasets

                % Build components matrix
                NIRS_components = [RH_C3,LH_C4,RH_C3,F_Cz];

        case 'JK' %------------------------------------------------------------
            % Dataset 001 -----------------------------------------------------
                [RH_1, LH_1, F_1, ~] = nirx_channels(NIRS_data);

                % C3_RH
                    RH_C3 = [mean(RH_1(:,1:2),2), mean(RH_1(:,3:4),2)];     
                % Cz_F
                    F_Cz = [mean(F_1(:,1:2),2), mean(F_1(:,3:4),2)];             
                % C4_LH   
                    LH_C4 = [mean(LH_1(:,1:2),2), mean(LH_1(:,3:4),2)]; 

                % Build components matrix
                NIRS_components = [LH_C4,RH_C3,LH_C4,RH_C3,F_Cz];

        case 'NC' %------------------------------------------------------------
            % Dataset 001 -----------------------------------------------------
                [RH_1, LH_1, F_1, ~] = nirx_channels(NIRS_data);

                % C3_RH
                    RH_C3 = [RH_1(:,4), RH_1(:,4)]; % Reject channels C5, C6, C9             
                                                            % Max 2 channels for all NC datasets
                % Cz_F0
                    F_Cz = F_1(:,[1,4]); % Reject channels C2, C11               
                % C4_LH
                    LH_C4 = LH_1(:,[3,4]); % Reject channels C15, C16

                % Build components matrix
                NIRS_components = [LH_C4,RH_C3,LH_C4,RH_C3,F_Cz];              

        case 'SC' %------------------------------------------------------------
            % Dataset 001 -----------------------------------------------------
                [RH_1, LH_1, F_1, ~] = nirx_channels(NIRS_data);

                % C3_RH
                    RH_C3 = [mean(RH_1(:,1:2),2), mean(RH_1(:,3:4),2)];           

                % Cz_F
                    F_Cz = [mean(F_1(:,1:2),2), mean(F_1(:,3:4),2)];              
                % C4_LH
                    LH_C4 = [mean(LH_1(:,1:2),2), mean(LH_1(:,3:4),2)];       

                % Build components matrix
                NIRS_components = [LH_C4,RH_C3,LH_C4,RH_C3];               
    end
    
            % For removing imagery states
            % LH_C4,
            % ,F_Cz
            % LH_C4,RH_C3,

elseif nargin == 3
    
    clearvars LH* RH* F*
    %% EEG Formatting ---------------------------------------------------------
    % Isolate signal data by state
    EEG_LH_C2  = EEG_opt(:,4); 
    EEG_LH_C4  = EEG_opt(:,5);
    EEG_RH_C3  = EEG_opt(:,1);
    EEG_RH_C1  = EEG_opt(:,2);
    EEG_BH_C2  = EEG_opt(:,4); 
    EEG_BH_C4  = EEG_opt(:,5);
    EEG_BH_C3  = EEG_opt(:,1);
    EEG_BH_C1  = EEG_opt(:,2);    
    EEG_F_Cz   = EEG_opt(:,3);
    EEG_F_FCz  = EEG_opt(:,7);

    % This section has the ability to eliminate channels
    switch subj
        case 'MRA'
            % Channels C2, C4, and FC2 eliminated
            EEG_components  = [EEG_RH_C3,EEG_RH_C1,EEG_BH_C2,EEG_BH_C4,EEG_BH_C3,EEG_BH_C1,EEG_F_Cz,EEG_F_FCz]; 
        case 'JK'
            % Channels C2, C4, and FC2 eliminated            
            EEG_components  = [EEG_RH_C3,EEG_RH_C1,EEG_BH_C2,EEG_BH_C4,EEG_BH_C3,EEG_BH_C1,EEG_F_Cz,EEG_F_FCz];
        case 'NC'
            % Channels C2, C4, and FC2 eliminated            
            EEG_components  = [EEG_RH_C3,EEG_RH_C1,EEG_BH_C2,EEG_BH_C4,EEG_BH_C3,EEG_BH_C1,EEG_F_Cz,EEG_F_FCz];
        case 'SC'
            % All channels present            
            EEG_components  = [EEG_RH_C3,EEG_RH_C1,EEG_BH_C2,EEG_BH_C4,EEG_BH_C3,EEG_BH_C1,EEG_F_Cz,EEG_F_FCz];
    end    
    
        % For removing imagery states
        % EEG_LH_C2,EEG_LH_C4,
        % ,EEG_F_Cz,EEG_F_FCz
    
end    

end

