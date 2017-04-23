%% EEG_NIRS_class.m
% Matthew McCann
% 7/10/2015

% This script loads relevant EEG training data, tEEG training data and NIRS 
% training data, upsamples the NIRS data to 256 Hz, and builds the 
% classifier matrices for a combined EEG/NIRS BCI. 

% Features extracted from EEG are: PSD of characteristic frequency, mean 
% and minimum PSD of frequency range spanning +/- 2 Hz of charactersitic 
% frequency, and the frequency at which the lowest PSD occurs in the
% characteristic range.

% Features extracted from NIRS data are: variance of [HbO], the slope of 
% the [HbO] vs. time vector and the second derivative for the 
% [HbO] vs. time vector. 

% The output classifier matrix/training set is consists of the EEG features
% first, then NIRS features, with the state vector as the final column in
% the matrix. 

% IMPORTANT: Channel elimination must be conducted on a subject by subject
% basis. Channels can be eliminated within the functions NIRX_setup.m and
% EEG_setup.m. Changes must also be made in make_classifier.m. For now, the
% subjects JK, MRA, and NC will be optimized with channel elimination to
% increase classification accuracy. Where needed, comments in this script
% will tell users where to change settings depending on the user, or where
% to change settings in functions for accurate classification

% NOTE: Variables that may affect classification are bin size and the
% inputs to movingslope.m. Bin size is 30 elements by default, with an 
% overlap of 50%. See help movingslope.m for definition of movingsope.m 
% inputs. By default, 3 points are used for a 1st order regression. dt is 
% spacing period of the signal 1/Fs_EEG

% For the subject used during developing, best results were achieved when
% Left Hand imagery states were rejected.

% Last Updated: 22 July, 2015
% Changelog 
%    22/7/2015: Allows for automatic building of test data set for offline
%    analysis. Updated file path for saved files.
%    21/7/2015: Addition of standard EEG data to classifier matrix. Same
%    features as tEEG are extracted

%% Initialize Workspace
clear; clf; close all; clc;

%% Establish initial variables
global Fs_EEG Fs_NIRX
Fs_EEG = 256;   % Hz
Fs_NIRX = 7.81; % Hz

%% Determine Subject
global direc
subj = input('Which subject? ','s');
data_type = input('train or test? ', 's');
direc = 'E:\McCann-Robot_hand\Matlab_Code\Subject_Data\';

%% Load tEEG data
    % Uses the function EEG_setup.m. Requires user to input the 
    % filename of the EEG data they wish to load. Will have form 
    % [features state]. Takes a while to run because EEG_setup.m is slow. 

    % Note: need to adjust EEG_setup.m for additional subjects
    [tEEG_components, tEEG_charfreq, tEEG_intfreq, tEEG_state] = EEG_setup(subj,data_type);   
    
%% Load EEG data
    % Uses the function EEG_setup.m. Requires user to input the 
    % filename of the EEG data they wish to load. Will have form 
    % [features state]. Takes a while to run because EEG_setup.m is slow. 

    % Note: need to adjust EEG_setup.m for additional subjects
    [EEG_components, EEG_charfreq, EEG_intfreq, EEG_state] = EEG_setup(subj,data_type);    
    
%% Housekeeping
clc;
clearvars -except tEEG* EEG* subj Fs* data_type direc

%% Load NIRX data
    % Uses fucntion NIRX_setup.m. Has output format [features, state].
    % Each of the left/right/both hand/feet states in the NIRX component state
    % has two channels. 
    
    % NOTE: need to adjust NIRX_setup.m for additional subjects
    NIRX_components = NIRX_setup(subj,tEEG_state,data_type);

%% Make bins and create classifier matrices
    % Check if EEG and NIRX matrices are the same size
    check_size = (size(tEEG_components) == size(NIRX_components));
    [r,c] = size(tEEG_components);
    
    % Define binning parameters *******************************************
    numEle = 30;                  % Number of elements in each bin 
    overlap = floor(numEle.*0.5); % Bins overlap by 50%
    % *********************************************************************
    
    % Make bins
        [numbins,~,binedges] = makebin(r,numEle,overlap);
        
    % Adjust bin edges if data length is shorter than makebin.m expects
        [r_end,c_end] = find(binedges >= r);
        binedges(:,c_end(1)+1:end) = [];
        binedges(end,end) = r;
        numbins = length(binedges);

    % tEEG
        bin_tEEG = zeros(numEle,c); %Create zeros matrix to accomodate a bin for each channel
        tEEG = bin_tEEG; % Create a matrix to house the different tEEG channels in different rows
    % EEG
        bin_EEG = zeros(numEle,c); %Create zeros matrix to accomodate a bin for each channel
        EEG = bin_EEG; % Create a matrix to house the different EEG channels in different rows
    % NIRX
        binNIRX = zeros(numEle,c); %Create zeros matrix to accomodate a bin for each channel
        NIRX = binNIRX; % Create a matrix to house the different NIRX channels in different rows

    % Predefine empty matrices to hold tEEG and EEG features
        % Define matrix to hold min PSD 
            tEEG_minPSD = zeros(numbins-1,c);
            EEG_minPSD = zeros(numbins-1,c);
        % Define matrix to hold min PSD frequencies
            tEEG_minfreq = zeros(numbins-1,c);
            EEG_minfreq = zeros(numbins-1,c);
        % Define matrix to hold characteristic frequency PSDs
            tEEG_charPSD = zeros(numbins-1,c); 
            EEG_charPSD = zeros(numbins-1,c); 
        % Define matrix to hold mean range PSDs
            tEEG_meanPSD = zeros(numbins-1,c); 
            EEG_meanPSD = zeros(numbins-1,c); 
        
    % Predefine empty matrices to hold NIRX features
        % Define matrix to hold mean slope values 
            NIRX_mean_slope = zeros(numbins-1,c);
        % Define matrix to hold second derivative
            NIRX_deriv2 = zeros(numbins-1,c);
         % Define matrix to hold HbO concentration variance
             NIRX_var_HbO = zeros(numbins-1,c);             

    % Set up first bins
        for i = 1:c
            tEEG(:,i) = tEEG_components((binedges(1,1)+1):binedges(2,1),i);
            EEG(:,i)  = EEG_components((binedges(1,1)+1):binedges(2,1),i);
            NIRX(:,i) = NIRX_components((binedges(1,1)+1):binedges(2,1),i);
        end
 
%% Feature Extraction

% Set up variables for using movingslope.m ********************************
slidingwindow = 3; % Three points for linear regression
order = 1;         % First order (linear) regression
dt = 1/Fs_EEG;     % Period is the time step.
% *************************************************************************    

for k = 2:numbins
        for l = 1:c
    % Collect new data/define new bin for state ---------------------------
        binsize = length(binedges(1,k)+1:binedges(2,k));
        bin_tEEG(1:binsize,l) = tEEG_components((binedges(1,k)+1):binedges(2,k),l);
        bin_EEG(1:binsize,l) = EEG_components((binedges(1,k)+1):binedges(2,k),l);
        binNIRX(1:binsize,l) = NIRX_components((binedges(1,k)+1):binedges(2,k),l);

    % tEEG ----------------------------------------------------------------
        % Find PSD of bin, minimum PSD, and frequency at which min occurs
            [pxx,f] = periodogram(tEEG(:,l),[],tEEG_intfreq(l,:),Fs_EEG);
            tEEG_charPSD(k-1,l) = pxx(f == tEEG_charfreq(l));
            tEEG_meanPSD(k-1,l) = mean(pxx);    
            tEEG_minPSD(k-1,l)  = min(pxx);
            tEEG_minfreq(k-1,l) = f(pxx == tEEG_minPSD(k-1,l));

    % EEG ----------------------------------------------------------------
        % Find PSD of bin, minimum PSD, and frequency at which min occurs
            [pxx,f] = periodogram(EEG(:,l),[],EEG_intfreq(l,:),Fs_EEG);
            EEG_charPSD(k-1,l) = pxx(f == EEG_charfreq(l));
            EEG_meanPSD(k-1,l) = mean(pxx);    
            EEG_minPSD(k-1,l)  = min(pxx);
            EEG_minfreq(k-1,l) = f(pxx == EEG_minPSD(k-1,l));                        
            
    % NIRX ----------------------------------------------------------------              
        % Find HbO variance     
             NIRX_var_HbO(k-1,l) = var(NIRX(:,l));
        % Find d[HbO]/dt 
            slope = movingslope(NIRX(:,l),slidingwindow,order,dt);
            NIRX_mean_slope(k-1,l) = mean(slope);
        % Find d2[HbO]/dt2    
            slope_slope = movingslope(slope,slidingwindow,order,dt);
            NIRX_deriv2(k-1,l) = mean(slope_slope);
        end
    
    % Redefine bins -------------------------------------------------------
        tEEG = bin_tEEG;
        EEG = bin_EEG;
        NIRX = binNIRX;
end
    
%% Hauskeeping
    clearvars -except NIRX_* EEG_* tEEG_* subj data_type direc
    
%% Create Classification Matrix
    [classifier, state] = make_classifier(subj, tEEG_meanPSD, tEEG_charPSD, tEEG_minPSD, tEEG_minfreq,...
        EEG_meanPSD, EEG_charPSD, EEG_minPSD, EEG_minfreq,...
        NIRX_var_HbO, NIRX_mean_slope, NIRX_deriv2);
        
    clearvars -except classifier state subj data_type direc
        
%% Save file
if strcmp(data_type, 'train')
    save(strcat(direc,subj,'_EEG_NIRX_classifier'));
elseif strcmp(data_type,'test')
    save(strcat(direc,subj,'_',data_type,'_EEG_NIRX_classifier'));
end
    