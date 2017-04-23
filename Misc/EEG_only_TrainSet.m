%% EEG_only_TrainSet.m
% Matthew McCann
% June 2015

% Last Updated: 20 July, 2015

% This script asks the user to load five training sets from given subject to
% create a tEEG classification matrix based on power spectral density (PSD)

%% Ask for subject label
global subj
subj = input('Which subject? ', 's');

%% Load all datasets for one subject
disp('Choose files to load for training.')
[parameters, sig1, state] = load_EEG('clean',subj); %Load first file
             [~, sig2, ~] = load_EEG('clean',subj);
             [~, sig3, ~] = load_EEG('clean',subj);
             [~, sig4, ~] = load_EEG('clean',subj);
             [~, sig5, ~] = load_EEG('clean',subj);
             
%% Remove uneccessary channels from data (only channels 1-7 are relevant)
% Channels 1-8 in the data sets represent all tEEG channels. However,
% visual analysis from BCI2000's OfflineAnlaysis.m shows that channel 8
% (FC2) is not useful in classifying the data, so it is ignored in this
% script.
sig1 = sig1(:,1:7); 
sig2 = sig2(:,1:7); 
sig3 = sig3(:,1:7); 
sig4 = sig4(:,1:7); 
sig5 = sig5(:,1:7);

%% Seperate states into targets
    % Set up global variables
    global Fs
    Fs = parameters.SamplingRate.NumericValue; %Get sampling frequency (Hz)
    clear parameters
    
    % Elongate state variable
        % We want to create a single long column of the state variable in 
        % order to combine all trials
        state = [state'; 
                 state'; 
                 state'; 
                 state'; 
                 state'];
    
    % Remove resting state data and find all places where channel states are true      
    rest = find(state == 0);
    left = find(state == 1);
    right = find(state == 2);
    hands = find(state == 3);
    feet = find(state == 4);
    
    clear state
%% Signals matrix decomposition

    % Combine signals matrices into one big matrix
    allChannels = [sig1; sig2; sig3; sig4; sig5];
    clearvars sig*    

    % Isolate resting state data
    restData = allChannels(rest,:);

    % Isolate signal data by state
    LH_C2 = allChannels(left,4); 
    LH_C4 = allChannels(left,5);
    RH_C3 = allChannels(right,1);
    RH_C1 = allChannels(right,2);
    BH_C2 = allChannels(hands,4);
    BH_C4 = allChannels(hands,5);
    BH_C3 = allChannels(hands,1);
    BH_C1 = allChannels(hands,2);
    F_Cz  = allChannels(feet,3);
    F_FCz = allChannels(feet,7);
    RH_FC1 = allChannels(right,6);
    
    % Create component matrix for easier evaluation. Channel elimination
    % occurs here.
    if strcmp(subj,'JK') == 1
        components  = [LH_C2,LH_C4,RH_C3,RH_C1,BH_C2,BH_C4,BH_C3,BH_C1,F_Cz,F_FCz,RH_FC1]; 
    elseif strcmp(subj,'MRA') == 1
        components  = [LH_C2,LH_C4,RH_C3,RH_C1,BH_C2,BH_C4,BH_C3,BH_C1,F_Cz,F_FCz];
    elseif strcmp(subj,'NC') == 1
        components  = [LH_C2,LH_C4,RH_C3,RH_C1,BH_C2,BH_C4,BH_C3,BH_C1,F_Cz];
    end
        
    
     clearvars place* allChannels
%% Interesting Frequency Range for each channel and classifier
% Based on data gathered through OfflineAnalysis.m in BCI2000. The format
% of this matrix follows to order of the channels given in the above
% section. The frequency ranges given are in Hz, and span the
% characteristic frequency +/- user-specified bounds in Hz.

switch subj
    case 'JK'
        char_freq = [11;  % C2_left 
                     13;  % C4_left 
                     3;   % C3_right 
                     31;  % C1_right 
                     3;   % C3_both
                     3;   % C1_both
                     13;  % C2_both
                     11;  % C4_both
                     11;  % Cz_feet
                     27;  % FC1_right
                     25]; % FCz_feet
      
    case 'MRA'
        char_freq = [3;   % C2_left 
                     15;  % C4_left 
                     5;   % C3_right 
                     5;   % C1_right 
                     15;  % C3_both
                     17;  % C1_both
                     13;  % C2_both
                     15;  % C4_both
                     7;   % Cz_feet 
                     17]; % FCz_feet
    case 'NC'
        char_freq = [9;   % C2_left 
                     11;  % C4_left 
                     9;   % C3_right 
                     9;   % C1_right 
                     3;   % C3_both
                     19;  % C1_both
                     7;   % C2_both
                     7;   % C4_both
                     7];  % Cz_feet 
end

% Set bounds for frequency range
bounds = 2;
EEG_intfreq = zeros(length(char_freq),(2.*bounds+1));

% Create a matrix 
for a = 1:length(char_freq)
    EEG_intfreq(a,:) = (char_freq(a)-bounds):(char_freq(a)+bounds);
end
%% Bins

    % Define binning parameters 
    [r,c] = size(components);
    numEle = 100; % Number of elements in each bin 
    overlap = 50; % Amount of overlap in each bin
    [numbins,~,binedges] = makebin(r,numEle,overlap);
    binEEG = zeros(numEle,c); %Create zeros matrix to accomodate a bin for each channel
    EEG = binEEG; % Create a matrix to house the different EEG channels in different rows

    % Define matrix to hold min PSD 
    minPSD = zeros(numbins-1,c);
    
    % Define matrix to hold min PSD frequencies
    minfreq = zeros(numbins-1,c);
    
    % Define matrix to hold characteristic frequency PSDs
    charPSD = zeros(numbins-1,c);
    
    % Define matrix to hold mean range PSDs
    meanPSD = zeros(numbins-1,c);
    
    % Set up first bins
        for b = 1:c
            EEG(:,b) = components((binedges(1,1)+1):binedges(2,1),b);
        end
        
%% Loop to calculate frequency with minimum power density within interesting range
for d = 2:numbins
    
    % Deal with EEG
        for e = 1:c
        % Collect new data/define new bin for state
            binEEG(:,e) = components((binedges(1,d)+1):binedges(2,d),e);     

        % Find PSD of bin, minimum PSD, and frequency at which min occurs
            [pxx,a] = periodogram(EEG(:,e),[],EEG_intfreq(e,:),Fs);
            meanPSD(d-1,e) = mean(pxx);
            minPSD(d-1,e) = min(pxx);
            minfreq(d-1,e) = a(pxx == minPSD(d-1,e));
            charPSD(d-1,e) = pxx(a == char_freq(e));   
        end
    
    % Redefine bins
    EEG = binEEG;
end

%% Give output as matrix that will contain state info and classifiers
% Here, ant channels eliminated in the component matrix created preocess
% must also be eliminated. To do this, simply comment out the correct line
% from each matrix. 

if strcmp(subj,'JK') == 1

    state = [ones(length(charPSD),1); 
                  ones(length(charPSD),1);  
                  %2.*ones(length(charPSD),1); reject RH_C3 
                  2.*ones(length(charPSD),1);
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  4.*ones(length(charPSD),1);
                  4.*ones(length(charPSD),1);
                  2.*ones(length(charPSD),1)];
          
    charPSD = [charPSD(:,1);
               charPSD(:,2);
               %charPSD(:,3); reject RH_C3
               charPSD(:,4);
               charPSD(:,5);
               charPSD(:,6);
               charPSD(:,7);
               charPSD(:,8);
               charPSD(:,9);
               charPSD(:,10);
               charPSD(:,11)];

    minPSD = [minPSD(:,1);
              minPSD(:,2);
              %minPSD(:,3); reject RH_C3
              minPSD(:,4);
              minPSD(:,5);
              minPSD(:,6);
              minPSD(:,7);
              minPSD(:,8);
              minPSD(:,9);
              minPSD(:,10);
              minPSD(:,11)];

    minfreq = [minfreq(:,1);
               minfreq(:,2);
               %minfreq(:,3); reject RH_C3
               minfreq(:,4);
               minfreq(:,5);
               minfreq(:,6);
               minfreq(:,7);
               minfreq(:,8);
               minfreq(:,9);
               minfreq(:,10);
               minfreq(:,11)];        

    meanPSD = [meanPSD(:,1);
               meanPSD(:,2);
               %meanPSD(:,3); reject RH_C3
               meanPSD(:,4);
               meanPSD(:,5);
               meanPSD(:,6);
               meanPSD(:,7);
               meanPSD(:,8);
               meanPSD(:,9);
               meanPSD(:,10);
               meanPSD(:,11)];

elseif strcmp(subj,'MRA') == 1
    
    state = [%ones(length(charPSD),1); reject LH_32
                  ones(length(charPSD),1);  
                  %2.*ones(length(charPSD),1); reject RH_C3 
                  2.*ones(length(charPSD),1);
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  4.*ones(length(charPSD),1);
                  %4.*ones(length(charPSD),1);reject F_FCz
                  %2.*ones(length(charPSD),1)reject RH_FC1
                  ];
          
    charPSD = [%charPSD(:,1); reject LH_C2
               charPSD(:,2);
               %charPSD(:,3); reject RH_C3
               charPSD(:,4);
               charPSD(:,5);
               charPSD(:,6);
               charPSD(:,7);
               charPSD(:,8);
               charPSD(:,9);
               %charPSD(:,10); reject F_FCz
               %charPSD(:,11)reject RH_FC1
               ];

    minPSD = [%minPSD(:,1); reject LH_C2
              minPSD(:,2);
              %minPSD(:,3); reject RH_C3
              minPSD(:,4);
              minPSD(:,5);
              minPSD(:,6);
              minPSD(:,7);
              minPSD(:,8);
              minPSD(:,9);
              %minPSD(:,10); reject F_FCz
              %minPSD(:,11)reject RH_FC1
              ];

    minfreq = [%minfreq(:,1); reject LH_C2
               minfreq(:,2);
               %minfreq(:,3); reject RH_C3
               minfreq(:,4);
               minfreq(:,5);
               minfreq(:,6);
               minfreq(:,7);
               minfreq(:,8);
               minfreq(:,9);
               %minfreq(:,10); reject F_FCz
               %minfreq(:,11)reject RH_FC1
               ];        

    meanPSD = [%meanPSD(:,1); reject LH_C2
               meanPSD(:,2);
               %meanPSD(:,3); reject RH_C3
               meanPSD(:,4);
               meanPSD(:,5);
               meanPSD(:,6);
               meanPSD(:,7);
               meanPSD(:,8);
               meanPSD(:,9);
               %meanPSD(:,10); reject F_FCz
              % meanPSD(:,11)reject RH_FC1
              ];
    
elseif strcmp(subj,'NC') == 1
    
    state = [ones(length(charPSD),1); 
                  ones(length(charPSD),1);  
                  2.*ones(length(charPSD),1); 
                  2.*ones(length(charPSD),1);
                  %3.*ones(length(charPSD),1); reject BH_C3
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  4.*ones(length(charPSD),1);
                 % 4.*ones(length(charPSD),1); reject F_FCz
                  %2.*ones(length(charPSD),1) reject RH_FC1
                  ];
          
    charPSD = [charPSD(:,1);
               charPSD(:,2);
               charPSD(:,3); 
               charPSD(:,4);
              % charPSD(:,5); reject BH_C3
               charPSD(:,6);
               charPSD(:,7);
               charPSD(:,8);
               charPSD(:,9);
              % charPSD(:,10); reject F_FCz
              % charPSD(:,11) reject RH_FC1
              ];

    minPSD = [minPSD(:,1);
              minPSD(:,2);
              minPSD(:,3);
              minPSD(:,4);
              %minPSD(:,5); reject BH_C3
              minPSD(:,6);
              minPSD(:,7);
              minPSD(:,8);
              minPSD(:,9);
              %minPSD(:,10); reject F_FCz
              %minPSD(:,11) reject RH_FC1
              ];

    minfreq = [minfreq(:,1);
               minfreq(:,2);
               minfreq(:,3); 
               minfreq(:,4);
               %minfreq(:,5); reject BH_C3
               minfreq(:,6);
               minfreq(:,7);
               minfreq(:,8);
               minfreq(:,9);
               %minfreq(:,10); reject F_FCz
               %minfreq(:,11) reject RH_FC1
               ];        

    meanPSD = [meanPSD(:,1);
               meanPSD(:,2);
               meanPSD(:,3); 
               meanPSD(:,4);
               %meanPSD(:,5); reject BH_C3
               meanPSD(:,6);
               meanPSD(:,7);
               meanPSD(:,8);
               meanPSD(:,9);
               %meanPSD(:,10); reject F_FCz
               %meanPSD(:,11) reject RH_FC1
               ]; 
end
       
%% Create classification matrix and delete unnecessary variables
classification = [charPSD, minPSD, minfreq, meanPSD, state];
clearvars -except classification subj

%% Save classification matrix to file
savefile = strcat('class_',subj);
save(strcat('E:\McCann-Robot_hand\Matlab Code\EEG\EEG_Matt\',subj,'\offline\EEG\',savefile));