%% Online_Classifier.m
% Matthew McCann
% 23 July, 2015

% This script incorporates all preprocessing, feature extraction, 
% classification, and hand control at once. Can be adapted to take in 
% active serial input from a tEEG/EEG/NIRS system.

% NOTE: At present, this script does NOT take in actively recorded singals.
% Instead, it treats a signal recorded from an online trial as an active
% input, runs it through a 256-element buffer, and executes the
% preprocssing, feature extraction, etc. on overlapping bins of 32 elements

% Last Updated: 2 August, 2015
% Changelog:
%    2/08/2015: Eliminated command window printing during automatic
%    artifact removal.
%    31/07/2015: Incorporated automatic EOG removal using pop_autobsseog.m
%    from eeglab. Need to find portion of code that prints things to screen
%    to speed up calculation
%    30/07/2015: Incorporated realtime filtering using EEGlab. Data is
%    classifiable, but does not yield good classification. Looking for way
%    to incorporate artifact removal in real time. For now, using online
%    data that is seperately prepreocessed in eeglab with only 60 Hz notch
%    filtering, and bpf from 5-35 Hz, and a 2nd order moving average filter.
%    29/07/2015: Added binning function to subdivide data in buffer to 125
%    ms increments for analysis. 
%    28/07/2015: Fully incorporated preprocessing, feature extraction, and 
%    classification. 
%    27/07/2015: Added global directory variable to simplify importing the
%    entire folder from computer to computer. EEG and tEEG data are 
%    filtered in this script as opposed to using eegLAB as was done in
%    offline analysis. 

%% Initialize Workspace ***************************************************
clear; clf; close all; clc;

%% Open Serial Connection *************************************************
% For now, the online files are loaded from the hard disk. Eventually, this
% portion of the code should be updated to open the serial connection and
% taken in data in real time.

% Connect to hand
global S
S = serial('COM6');
set(S, 'Terminator', 'CR/LF');
set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
fopen(S);

%% Get subject and define directory ***************************************
global subj direc
subj = input('Which subject? ', 's');
direc = 'E:\McCann-Robot_hand\Matlab_Code\';

%% Load classifier matrix from offline data and get coefficients matrix ***
load(strcat(direc,'EEG_NIRX_classifiers\',subj,'_noEEG_NIRX_noF_classifier'));
W = LDA(classifier,state);

%% Load online files ******************************************************
% For now, the online files are saved to a hard disk. In future versions,
% the parameters, on_target, and on_result variables will not be loaded,
% and only the raw data will be collected via a serial connection

% tEEG
[parameters, on_tEEG, on_target, ~] = load_online_EEG();
on_tEEG = double(on_tEEG);
on_tEEG = on_tEEG'; %If entering cleaned data

% EEG

% NIRS
C = import_online_HbO('008');

%% Adjust on_target to compensate for imagery elimination
chanElim = input('Are any imagery states removed? (no/LH/RH/BH/F) ','s');
if strcmp(chanElim,'no')
    % Do nothing
elseif strcmp(chanElim,'LH')
    remove = find(on_target == 1);
    on_target(remove) = 0;
elseif strcmp(chanElim,'RH')
    remove = find(on_target == 2);
    on_target(remove) = 0;
elseif strcmp(chanElim,'BH')
    remove = find(on_target == 3);
    on_target(remove) = 0;    
elseif strcmp(chanElim,'F')
    remove = find(on_target == 4);
    on_target(remove) = 0;    
end
    
clc;
%% Variables **************************************************************
% sampling rate, etc.
    global Fs_EEG Fs_NIRS
    Fs_EEG = parameters.SamplingRate.NumericValue;
    Fs_NIRS = 7.81; % Hz. 
    clear parameters
    
% Size of tEEG data
    [r_tEEG,c_tEEG] = size(on_tEEG);    
    
%% Upsample NIRS data, pad with zeros if too small
% Upsample
[P,Q] = rat(Fs_EEG/Fs_NIRS, 1e-9);  
on_NIRS = resample(C,P,Q);
clear C

% Pad with zeros if necessary to reach equaivalent dataset size
[r_NIRS,c_NIRS] = size(on_NIRS);

    % If nirs data too small, add zeros to NIRS
    if r_NIRS < r_tEEG
        diff = r_tEEG - r_NIRS;
        on_NIRS = padarray(on_NIRS,[diff 0],'post');
    % If EEG data too small, add zeros to EEG and target/result states
    elseif r_tEEG < r_NIRS
        diff = r_NIRS - r_tEEG;
        on_tEEG = padarray(on_tEEG,[diff 0],'post');
        % Also pad target state for easier manipulation
        on_target = padarray(on_target,[diff 0],'post');  
    end

% Pad with zeros to make datasets evenly divisible by 256
    buffsize = Fs_EEG;  % Number of datapoints to take into buffer at once.
    [r_new, c_new] = size(on_tEEG);
    div = ceil(r_new/buffsize) + 1; % Add bin of zeros as a marker to exit while loop
    newlength = div*buffsize; 
    on_tEEG = padarray(on_tEEG,[newlength-r_new 0],'post'); % Add zeros to the end of the matrix
    on_NIRS = padarray(on_NIRS,[newlength-r_new 0],'post'); % Add zeros to the end of the matrix
    on_target = padarray(on_target,[newlength-r_new 0],'post'); % Add zeros to the end of the matrix

%% Get tEEG & EEG Characteristic Frequencies ******************************
% Make sure to check if correct channels are eliminated
[intfreq_tEEG, char_freq_tEEG] = get_EEG_char_freqs('tEEG');
%[intfreq_EEG, char_freq_EEG] = get_EEG_char_freqs('EEG');      

%% Collect initial resting state data for baseline removal ****************
% Take in 2 seconds of data at once and take average to get baseline.
% Mean of channels are taken by columns.

% tEEG
    buff_tEEG = zeros(2*Fs_EEG,c_tEEG);  
% EEG
%     buff_EEG = zeros(2*Fs_EEG,c_tEEG); 
% NIRS
    buff_NIRS = zeros(2*Fs_EEG,c_NIRS);

for i = 1:c_tEEG
    buff_tEEG(:,i) = on_tEEG(1:2*Fs_EEG,i);
end

for j = 1:c_NIRS
    buff_NIRS(:,j) = on_NIRS(1:2*Fs_EEG,j);
end
    
    baseline_tEEG = mean(buff_tEEG);
%     baseline_EEG = mean(buff_EEG);
    baseline_NIRS = mean(buff_NIRS);    

%% Set up bins ************************************************************

% Window bins -------------------------------------------------------------
winEle = Fs_EEG;
win_overlap = floor(winEle.*0.5);

% Make bins
    [~,~,winedges] = makebin(r_tEEG,winEle,win_overlap);

% Subbins -----------------------------------------------------------------

numEle = 32;                  % Number of elements in each bin 
overlap = floor(numEle.*0.5); % Bins overlap by 50%

% Make bins
    [numbins,~,binedges] = makebin(buffsize,numEle,overlap);
    
% Preallocate matrices for classifications 
    class = zeros(numbins,4);
    target = zeros(numbins,1);
    
% Preallocate matrices to store 1-second data
    class_1sec = zeros(div,4);
    target_state = zeros(div,1);
    
%% Housekeeping before main processes *************************************   
clearvars -except W subj direc on* buff* baseline* intfreq* char* stop* pass* b* a* S numbins winedges binedges Fs*

%% Create tEEG structure for automatic artifact rejection
% This portion is necessary to run automatic EOG removal. This array
% contains only the data necessary to run pop_autobsseog.m. Because the
% chanlocs cell is a structure itself, it is simply loaded from the
% Subject_Data directory in the hard disk.
load(strcat(direc,'Subject_Data\chanlocs.mat'));

tEEG = struct;
tEEG.data = [];
tEEG.pnts = Fs_EEG;
tEEG.srate = Fs_EEG;
tEEG.nbchan = 8;
tEEG.chanlocs = chanlocs;
tEEG.trials = 1;

%% Collect Data, Process, and Classify ************************************
getData = 1; % Set flag for while loop
count = 3;  % Set counter for data extraction

while (getData == 1)
    
    % Get Data - collect one second of data -------------------------------
        buff_tEEG = on_tEEG(winedges(1,count):winedges(2,count),:);
        buff_NIRS = on_NIRS(winedges(1,count):winedges(2,count),:);
        buff_target = on_target(winedges(1,count):winedges(2,count),:);
    
    % Check if end of signal has been reached ----------------------------- 
        endcheck_NIRS = find(buff_NIRS(:,1) == 0);
        endcheck_NIRS = length(endcheck_NIRS);
        endcheck_tEEG = find(buff_tEEG(:,1) == 0);
        endcheck_tEEG = length(endcheck_tEEG);
        
        if endcheck_NIRS >= ceil(length(buff_NIRS)/3)
            getData = 0;
            break
        elseif endcheck_tEEG >= ceil(length(buff_tEEG)/3)
            getData = 0;
            break
        end        
   
    % Preprocess ----------------------------------------------------------
        % In future versions, active channel rejection and artifact
        % rejection should be incorporated. For now, this is beyond the
        % scope of this project.

         % tEEG
         % If loading cleaned tEEG data, comment out lines 238-244
         
         buff_tEEG = bsxfun(@minus,buff_tEEG,baseline_tEEG); % Remove baseline
%          buff_tEEG = buff_tEEG'; 
%          filt_tEEG = eegfilt(buff_tEEG,Fs_EEG,0,55,Fs_EEG,84); % Notch filter at 60 Hz          
%          filt_tEEG = eegfilt(filt_tEEG,Fs_EEG,0,35,Fs_EEG,84); % Lowpass filter at 35 Hz
%          filt_tEEG = eegfilt(filt_tEEG,Fs_EEG,5,0,Fs_EEG,84); % Highpass filter at 5 H
%          tEEG.data = filt_tEEG; % Put current window into stucture array for auto EOG removal
%          filt_EEG = pop_autobsseog(tEEG,[32],[32],'sobi',{'eigratio', [1000000]},'eog_fd',{'range',[0  2]}); 
%          filt_tEEG = tEEG.data';
         filt_tEEG = medfilt1(buff_tEEG,4); % 4 element median filter

        % EEG    

         % NIRS
%               For the current setup, the NIRS data will be preprocessed in nirsLAB
%               since the raw dataset is difficult to manage. However, no
%               channel rejection will take place here. In future versions, the
%               data should be actively filtered from 0.01 - 0.1 Hz and
%               converted to HbO values for feature extraction. When running
%               NIRSlab, use existing nirsInfo.mat files, or use raw data and
%               use NIRS_event_info file and probeInfo file in
%               E:\McCann-Robot_Hand for setup.;  
            buff_NIRS = bsxfun(@minus,buff_NIRS,baseline_NIRS); % Remove baseline

% *************************************************************************            
    % Break into bins of 0.125 second (32 element) length with 50% overlap    
     for k = 1:numbins  
        
         % Bin Data -----------------------------------------------------------
            bin_tEEG = filt_tEEG(binedges(1,k):binedges(2,k),:);
            bin_NIRS = buff_NIRS(binedges(1,k):binedges(2,k),:);
            bin_target = buff_target(binedges(1,k):binedges(2,k),:);
         
        % Data Manipulation - get data into right format ----------------------
            % Puts EEG and NIRS data into format [LH RH BH BH F]
                [tEEG_components, NIRS_components] = format_EEG_NIRS(bin_tEEG, bin_NIRS);

        % Feature Extraction --------------------------------------------------
            % Change settings for movingslope.m inside this function
            % tEEG/EEG features = [charPSD,meanPSD,minPSD,minfreq]
            % NIRS features = [HbO_variance,NIRS_slope,NIRS_deriv2]

                [tEEG_charPSD,tEEG_meanPSD,tEEG_minPSD,tEEG_minfreq,NIRS_var_HbO,NIRS_slope,NIRS_deriv2] ...
                  = get_features(tEEG_components,intfreq_tEEG,char_freq_tEEG,NIRS_components);

        % Classifier formatting -----------------------------------------------
            [test_data] = make_online_classifier(tEEG_charPSD,tEEG_meanPSD,tEEG_minPSD,tEEG_minfreq,...
                             NIRS_var_HbO,NIRS_slope,NIRS_deriv2);    

        % Classification ------------------------------------------------------
             L = [ones(size(test_data,1),1) test_data] * W';
             P = exp(L) ./ repmat(sum(exp(L),2),[1,3]);

        % Threshold data with hysteresis --------------------------------------          
            P = set_threshold(P);

        % Define state of each bin. For now, take the mean of the
        % classified observations in each bin. This gives an idea of how
        % close that bin is to certain imagery state.
            class(k,:) = mean(P);
%             class(k,:) = mode(P);
            
        % Rerun thresholding
            for p = 1:size(class(k,:),2)
                if (class(k,p) < 0.3)
                    class(k,p) = 0;
                elseif (class(k,p) > 0.6)
                    class(k,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(class(k,:));
                    column = find(class(k,:) == max_prob);
                    not_column = find(class(k,:) ~= max_prob);
                    class(k,column) = 1;
                    class(k,not_column) = 0;
                end
            end
        
        
     end
% *************************************************************************

    % Compile data into 1-second bins -------------------------------------
        class_1sec(count,:) = mode(class);
        
    % Get target state information ----------------------------------------
        target_state(count) = mode(buff_target);
        
    % Hand Movement -------------------------------------------------------
     it_moves(P);
      
    % Update Counter ------------------------------------------------------
        count = count + 1;
        
end

%% Close Serial Connection ************************************************
fclose(S);

%% Plots ******************************************************************
states = ['Left Hand Imagery ';'Right Hand Imagery';'Both Hands Imagery'];
        % For eliminating imagery
        %'Left Hand Imagery ';
        % ;'Feet Imagery      '
        % 'Both Hands Imagery';
statelabels = cellstr(states);

% 1-second increments
figure()
title('Classification vs. Known Class')
for h = 1:size(class_1sec,2)
    subplot(size(class_1sec,2)+1,1,h), plot(class_1sec(:,h),'b.')
    title(statelabels(h));    
    if h == 3, ylabel('Probability of Belonging to this Class'), end    
end
subplot(size(class_1sec,2)+1,1,h+1), plot(target_state,'r.')
title('Actual States')
xlabel('Seconds')