function components = NIRX_setup(subj,state,data_type)
%% NIRX_setup.m
% Matthew McCann
% 14 July, 2015

% Loads preprocessed NIRS data and formats the data into a usable format
% for feature extraction. Channel rejection occurs within this script. 

% NOTE: The output of the components matrix must change based on subject.
% Eliminating bad magery states increases classification accuracy. Go to line
% 286 for subject-dependent changes in the training matrix, and line 386
% for testing data. To eleminiate individual channels in training data, see
% lines 75-282, and to eliminate individual channels in testing data, see
% lines 315-353.

% Last Updated: 27 July, 2015
% Changelog
%   27/7/2015: Aded LH imagery to subject SC
%   22/7/2015: Added ability to load test datasets independently of
%   training datasets using the variable data_type.

%% Global variables
global Fs_EEG Fs_NIRX

%% Load files

% TRAINING DATA ***********************************************************
if strcmp(data_type, 'train') % *******************************************
    
        % Note that data and channels will be imported in numerical order - check
        % channel cell for column labels
        data_001 = import_HbO(subj,'001');
        data_002 = import_HbO(subj,'002');
        data_003 = import_HbO(subj,'003');
        data_004 = import_HbO(subj,'004');
        data_005 = import_HbO(subj,'005');

        %% Load and upsample data to match EEG sampling rate
        % Note: NIRS data is sampled at 7.81 Hz; upsampling to 256 Hz allows
        % for easier analysis of the NIRS and EEG data simultaneously.

        % Resample state
        [P,Q] = rat(Fs_EEG/Fs_NIRX, 1e-9);  

        data_001 = resample(data_001,P,Q);
        data_002 = resample(data_002,P,Q);
        data_003 = resample(data_003,P,Q);
        data_004 = resample(data_004,P,Q);
        data_005 = resample(data_005,P,Q);

        %% Break data into relevant channels
        % Note that not all data sets will have the same number of channels. This
        % must be done manually with new cases, but the switch structure here will
        % work for predefined subjects. When not all channels are present for each
        % data set, the means of channels for each electrode location are taken to
        % reduce the number of channels to the lowest number per location. 
            % Ex: Location Cz has all NIRS channels for each trial, but C3 only
            % has 2 useable channels for one or more trials. Reduce the number of
            % channels for ALL locations to 2 distinct channels by taking means of 
            % nearest neighbor channels 

            % In cases where only one channel is present at a given location, the
            % number of channels is reduced to 2 at all locations, with the single
            % channel doubled.

        % Further: channels 5,6,9,10 = C3_RH, channels 1,2,11,12 = Cz_F, 
        % channels 15,16,19,20 = C4_LH

        % Channel rejection is completed here. For the subjects given, chosen
        % channels were pre-labelled. For real channel rejection, use nirslab.m to
        % do visual channel rejection and preprocessing. 

        switch subj
            case 'MRA' %-----------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);            

                    % C3_RH
                        RH_C3_001 = RH_001(:,[2,4]); % Reject channels C5, C9
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), F_001(:,4)]; % Reject channel C11     
                    % C4_LH
                        LH_C4_001 = [LH_001(:,4), LH_001(:,4)]; % Reject channels C15, C16, C19 
                                                                % Max 2 channels for all MRA datasets
                % Dataset 002 -----------------------------------------------------
                    [RH_002, LH_002, F_002, ~] = nirx_channels(data_002);

                    % C3_RH
                        RH_C3_002 = RH_002(:,[2,4]); % Reject channels C5, C9            
                    % Cz_F
                        F_Cz_002 = [mean(F_002(:,1:2),2), F_002(:,4)]; % Reject channel C11 
                    % C4_LH
                        LH_C4_002 = [LH_002(:,4),LH_002(:,4)]; % Reject channels C15, C16, C19 

                % Dataset 003 -----------------------------------------------------
                    [RH_003, LH_003, F_003, ~] = nirx_channels(data_003);

                    % C3_RH
                        RH_C3_003 = RH_003(:,[2,4]); % Reject channels C5, C9 
                    % Cz_F          
                        F_Cz_003 = [mean(F_003(:,1:2),2), mean(F_003(:,3:4),2)];  
                    % C4_LH        
                        LH_C4_003 = [LH_003(:,4),LH_003(:,4)]; % Reject channels C15, C16, C19    

                % Dataset 004 -----------------------------------------------------
                    [RH_004, LH_004, F_004, ~] = nirx_channels(data_004);

                    % C3_RH
                        RH_C3_004 = RH_004(:,[2,4]); % Reject channels C5, C9     
                    % Cz_F
                        F_Cz_004 = [mean(F_004(:,1:2),2), mean(F_004(:,3:4),2)];  
                    % C4_LH 
                        LH_C4_004 = [mean(LH_004(:,1:2),2), LH_004(:,4)]; % Reject channel C19  

                % Dataset 005 -----------------------------------------------------
                    [RH_005, LH_005, F_005, ~] = nirx_channels(data_005);

                    % C3_RH       
                        RH_C3_005 = RH_005(:,[2,4]); % Reject channels C5, C9  
                    % Cz_F
                        F_Cz_005 = [mean(F_005(:,1:2),2), mean(F_005(:,3:4),2)];      
                    % C4_LH
                        LH_C4_005 = LH_005(:,[2,4]); % Reject channels C16, C19 

                  clearvars RH_00* LH_00* F_00* chan* data*    % More housekeeping

            case 'JK' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);

                    % C3_RH
                        RH_C3_001 = [mean(RH_001(:,1:2),2), mean(RH_001(:,3:4),2)];     
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), mean(F_001(:,3:4),2)];             
                    % C4_LH   
                        LH_C4_001 = [mean(LH_001(:,1:2),2), mean(LH_001(:,3:4),2)]; 

                % Dataset 002 -----------------------------------------------------
                    [RH_002, LH_002, F_002, ~] = nirx_channels(data_002);

                    % C3_RH
                        RH_C3_002 = [RH_002(:,2), mean(RH_002(:,3:4),2)]; % Reject channels C5           
                    % Cz_F     
                        F_Cz_002 = [mean(F_002(:,1:2),2), mean(F_002(:,3:4),2)]; 
                    % C4_LH
                        LH_C4_002 = [LH_002(:,2), mean(LH_002(:,3:4),2)]; % Reject channel C15            

                % Dataset 003 -----------------------------------------------------
                    [RH_003, LH_003, F_003, ~] = nirx_channels(data_003);

                    % C3_RH  
                        RH_C3_003 = [RH_003(:,2), mean(RH_003(:,3:4),2)]; % Reject channels C5  
                    % Cz_F
                        F_Cz_003 = [mean(F_003(:,1:2),2), mean(F_003(:,3:4),2)];     
                    % C4_LH 
                        LH_C4_003 = LH_003(:,[2,4]); % Reject channels C16, C19                        
                                                     % Max 2 channels for all JK datasets

                % Dataset 004 -----------------------------------------------------
                    [RH_004, LH_004, F_004, ~] = nirx_channels(data_004);

                    % C3_RH
                        RH_C3_004 = [mean(RH_004(:,1:2),2), mean(RH_004(:,3:4),2)]; 
                    % Cz_F
                        F_Cz_004 = [mean(F_004(:,1:2),2), mean(F_004(:,3:4),2)];         
                    % C4_LH
                        LH_C4_004 = [mean(LH_004(:,1:2),2), LH_004(:,4)]; % Reject channel C19

                % Dataset 005 -----------------------------------------------------
                    [RH_005, LH_005, F_005, ~] = nirx_channels(data_005);

                    % C3_RH
                        RH_C3_005 = [mean(RH_005(:,1:2),2), mean(RH_005(:,3:4),2)];  
                    % Cz_F
                        F_Cz_005 = [mean(F_005(:,1:2),2), mean(F_005(:,3:4),2)];    
                    % C4_LH
                        LH_C4_005 = [mean(LH_005(:,1:2),2), mean(LH_005(:,3:4),2)]; 

                  clearvars RH_00* LH_00* F_00* chan* data*    % More housekeeping

            case 'NC' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);

                    % C3_RH
                        RH_C3_001 = [RH_001(:,4), RH_001(:,4)]; % Reject channels C5, C6, C9             
                                                                % Max 2 channels for all NC datasets
                    % Cz_F0
                        F_Cz_001 = F_001(:,[1,4]); % Reject channels C2, C11               
                    % C4_LH
                        LH_C4_001 = LH_001(:,[3,4]); % Reject channels C15, C16

                % Dataset 002 -----------------------------------------------------
                    [RH_002, LH_002, F_002, ~] = nirx_channels(data_002);

                    % C3_RH
                        RH_C3_002 = [RH_002(:,4), RH_002(:,4)]; % Reject channels C5, C6, C9   
                    % Cz_F
                        F_Cz_002 = F_002(:,[1,2]); % Reject channels C1, C2
                    % C4_LH 
                        LH_C4_002 = LH_002(:,[3,4]); % Reject channels C15, C16

                % Dataset 003 -----------------------------------------------------
                    [RH_003, LH_003, F_003, ~] = nirx_channels(data_003); 

                    % C3_RH
                        RH_C3_003 = RH_003(:,[2,4]); % Reject channels C5, C9
                    % Cz_F
                        F_Cz_003 = F_003(:,[1,2]); % Reject channels C11, C12       
                    % C4_LH
                        LH_C4_003 = [LH_003(:,2), mean(LH_003(:,3:4),2)]; % Reject channel C15

                % Dataset 004 -----------------------------------------------------
                    [RH_004, LH_004, F_004, ~] = nirx_channels(data_004);    

                    % C3_RH   
                        RH_C3_004 = [RH_004(:,4), RH_004(:,4)]; % Reject channels C5, C6, C9       
                    % Cz_F
                        F_Cz_004 = F_004(:,[2,4]); % Reject channels C11, C12     
                    % C4_LH   
                        LH_C4_004 = LH_004(:,[3,4]); % Reject channels C15, C16

                % Dataset 005 -----------------------------------------------------
                    [RH_005, LH_005, F_005, ~] = nirx_channels(data_005);

                    % C3_RH
                        RH_C3_005 = [RH_005(:,4), RH_005(:,4)]; % Reject channels C5, C6, C9     
                    % Cz_F
                        F_Cz_005 = [F_005(:,2), F_005(:,2)]; % Reject channels C1, C11, C12
                    % C4_LH
                        LH_C4_005 = LH_005(:,[3,4]); % Reject channels C11, C12 
                        
            case 'SC' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);

                    % C3_RH
                        RH_C3_001 = [mean(RH_001(:,1:2),2), mean(RH_001(:,3:4),2)];           
                                                                
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), mean(F_001(:,3:4),2)];              
                    % C4_LH
                        LH_C4_001 = [mean(LH_001(:,1:2),2), mean(LH_001(:,3:4),2)]; 

                % Dataset 002 -----------------------------------------------------
                    [RH_002, LH_002, F_002, ~] = nirx_channels(data_002);

                    % C3_RH
                        RH_C3_002 = [mean(RH_002(:,1:2),2), mean(RH_002(:,3:4),2)];
                    % Cz_F
                        F_Cz_002 = [mean(F_002(:,1:2),2), mean(F_002(:,3:4),2)]; 
                    % C4_LH 
                        LH_C4_002 = [mean(LH_002(:,1:2),2), mean(LH_002(:,3:4),2)];

                % Dataset 003 -----------------------------------------------------
                    [RH_003, LH_003, F_003, ~] = nirx_channels(data_003); 

                    % C3_RH
                        RH_C3_003 = [mean(RH_003(:,1:2),2), mean(RH_003(:,3:4),2)];
                    % Cz_F
                        F_Cz_003 = [mean(F_003(:,1:2),2), mean(F_003(:,3:4),2)];      
                    % C4_LH
                        LH_C4_003 = [mean(LH_003(:,1:2),2), mean(LH_003(:,3:4),2)]; 

                % Dataset 004 -----------------------------------------------------
                    [RH_004, LH_004, F_004, ~] = nirx_channels(data_004);    

                    % C3_RH   
                        RH_C3_004 = [mean(RH_004(:,1:2),2), mean(RH_004(:,3:4),2)];    
                    % Cz_F
                        F_Cz_004 = [mean(F_004(:,1:2),2), mean(F_004(:,3:4),2)];     
                    % C4_LH   
                        LH_C4_004 = [mean(LH_004(:,1:2),2), mean(LH_004(:,3:4),2)]; 

                % Dataset 005 -----------------------------------------------------
                    [RH_005, LH_005, F_005, ~] = nirx_channels(data_005);

                    % C3_RH
                        RH_C3_005 = [mean(RH_005(:,1:2),2), mean(RH_005(:,3:4),2)];       
                    % Cz_F
                        F_Cz_005 = [mean(F_005(:,1:2),2), mean(F_005(:,3:4),2)];   
                    % C4_LH
                        LH_C4_005 = [mean(LH_005(:,1:2),2), mean(LH_005(:,3:4),2)];                       
        end             

                  clearvars RH_00* LH_00* F_00* chan* data*    % More housekeeping

        % Create large matrices for each movement
        LH = single([LH_C4_001;LH_C4_002;LH_C4_003;LH_C4_004;LH_C4_005]);
        F = single([F_Cz_001;F_Cz_002;F_Cz_003;F_Cz_004;F_Cz_005]);
        RH = single([RH_C3_001;RH_C3_002;RH_C3_003;RH_C3_004;RH_C3_005]);

        clearvars LH_C4* RH_C3* F_Cz* 

% TESTING DATA *************************************************************************
elseif strcmp(data_type, 'test') % ****************************************
        setnum = input('Which NIRS dataset for testing? ', 's');   
        % Load data
            % Note that data and channels will be imported in numerical order - check
            % channel cell for column labels
            data_001 = import_HbO(subj,setnum);

        % Resample state
            [P,Q] = rat(Fs_EEG/Fs_NIRX, 1e-9);  

            data_001 = resample(data_001,P,Q);

        % Break into relevant channels
        switch subj
            case 'MRA' %-----------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);            

                    % C3_RH
                        RH_C3_001 = RH_001(:,[2,4]); % Reject channels C5, C9
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), F_001(:,4)]; % Reject channel C11     
                    % C4_LH
                        LH_C4_001 = [LH_001(:,4), LH_001(:,4)]; % Reject channels C15, C16, C19 
                                                                % Max 2 channels for all MRA datasets
            case 'JK' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);

                    % C3_RH
                        RH_C3_001 = [mean(RH_001(:,1:2),2), mean(RH_001(:,3:4),2)];     
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), mean(F_001(:,3:4),2)];             
                    % C4_LH   
                        LH_C4_001 = [mean(LH_001(:,1:2),2), mean(LH_001(:,3:4),2)]; 
            case 'NC' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);

                    % C3_RH
                        RH_C3_001 = [RH_001(:,4), RH_001(:,4)]; % Reject channels C5, C6, C9             
                                                                % Max 2 channels for all NC datasets
                    % Cz_F0
                        F_Cz_001 = F_001(:,[1,4]); % Reject channels C2, C11               
                    % C4_LH
                        LH_C4_001 = LH_001(:,[3,4]); % Reject channels C15, C16
 
            case 'SC' %------------------------------------------------------------
                % Dataset 001 -----------------------------------------------------
                    [RH_001, LH_001, F_001, ~] = nirx_channels(data_001);

                    % C3_RH
                        RH_C3_001 = [mean(RH_001(:,1:2),2), mean(RH_001(:,3:4),2)];           
                                                                
                    % Cz_F
                        F_Cz_001 = [mean(F_001(:,1:2),2), mean(F_001(:,3:4),2)];              
                    % C4_LH
                        LH_C4_001 = [mean(LH_001(:,1:2),2), mean(LH_001(:,3:4),2)];                      
        end

        % Create large matrices for each movement
        LH = single(LH_C4_001);
        F = single(F_Cz_001);
        RH = single(RH_C3_001);

        clearvars LH_C4* RH_C3* F_Cz* 

end

%% Signals matrix decomposition

% Find events
rest = find(state == 0);
left = find(state == 1);
right = find(state == 2);
both = find(state == 3);
feet = find(state == 4);

% find average baseline
LH_R = mean(LH(rest,:));
RH_R = mean(RH(rest,:));
F_R  = mean(F(rest,:));

% make state-based matrices and remove baseline
LH_1 = bsxfun(@minus,LH(left,:),LH_R); LH_2 = bsxfun(@minus,LH(right,:),LH_R); LH_3 = bsxfun(@minus,LH(both,:),LH_R); LH_4 = bsxfun(@minus,LH(feet,:),LH_R); 
F_1  = bsxfun(@minus,F(left,:),F_R);   F_2  = bsxfun(@minus,F(right,:),F_R);   F_3  = bsxfun(@minus,F(both,:),F_R);   F_4  = bsxfun(@minus,F(feet,:),F_R);
RH_1 = bsxfun(@minus,RH(left,:),RH_R); RH_2 = bsxfun(@minus,RH(right,:),RH_R); RH_3 = bsxfun(@minus,RH(both,:),RH_R); RH_4 = bsxfun(@minus,RH(feet,:),RH_R);
clearvars left right both feet rest 

% Create new data and state matrices
% Here is where channel elimination takes place. This must be determined by
% trial and error. Make sure that the same locations are eliminated from
% the corresponding EEG dataset in EEG_setup.m
switch subj
    case 'MRA'
        % Eliminate left hand imagery components
        % LH_1
        components = [RH_2,LH_3,RH_3,F_4];
    case 'JK'
        components = [RH_2,LH_3,RH_3,F_4];
    case 'NC'
        components = [RH_2,LH_3,RH_3,F_4]; 
    case 'SC'
        components = [LH_1,RH_2,LH_3,RH_3,F_4];         
end

clearvars -except components

end