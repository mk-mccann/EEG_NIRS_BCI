%% EEG_only_Learn.m
% Matthew McCann
% June 2015

% Last Updated: 20 July, 2015

% This script loads a preprocessed data file and extracts the features
% necessary for classification using LDA.m. The training set built for the
% subject in EEG_only_TrainSet.m is used for teaching the algorithm. 

%% Initialize Workspace
clear;clf;close all; clc;

%% Ask for subject label
subj = input('Which subject? ', 's');

%% Load dataset for one subject
disp('Choose files to load for testing.')
[parameters, test_sig, test_state] = load_EEG('clean',subj); %Load file for classification
             
%% Remove uneccessary channels from data (only channels 1-7 are relevant)
% Ignore channel 8 (FC2)
test_sig = test_sig(:,1:7); 

%% Seperate states into targets
    % Set up global variables
    global Fs
    Fs = parameters.SamplingRate.NumericValue; %Get sampling frequency (Hz)
    clear parameters
    
    % Remove resting state data and find all places where channel states are true      
    rest = find(test_state == 0);
    left = find(test_state == 1);
    right = find(test_state == 2);
    hands = find(test_state == 3);
    feet = find(test_state == 4);
    
    clear state
%% Signals matrix decomposition

    % Combine signals matrices into one big matrix
    allChannels = test_sig;
    clearvars test*    

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
    
    % Create component matrix for easier evaluation
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
for f = 1:length(char_freq)
    EEG_intfreq(f,:) = (char_freq(f)-bounds):(char_freq(f)+bounds);
end
%% Power Spectral Density

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
        for i = 1:c
            EEG(:,i) = components((binedges(1,1)+1):binedges(2,1),i);
        end
        
%% Loop to calculate frequency with minimum power density within interesting range
for j = 2:numbins
    
    % Deal with EEG
        for l = 1:c
        % Collect new data/define new bin for state
            binEEG(:,l) = components((binedges(1,j)+1):binedges(2,j),l);     

        % Find PSD of bin, minimum PSD, and frequency at which min occurs
            [pxx,f] = periodogram(EEG(:,l),[],EEG_intfreq(l,:),Fs);
            meanPSD(j-1,l) = mean(pxx);
            minPSD(j-1,l) = min(pxx);
            minfreq(j-1,l) = f(pxx == minPSD(j-1,l));
            charPSD(j-1,l) = pxx(f == char_freq(l));    
        end
    
    % Redefine bins
    EEG = binEEG;
end

%% Give output as matrix that will contarin state info and classifiers 
% Change based on subject. Eliminate electrodes by commenting out the
% relevant channels. The electrode order by row may change by subject, but
% can be found in the section where the frequency range is established.

if strcmp(subj,'JK') == 1
    
    test_state = [ones(length(charPSD),1); 
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
    
    test_state = [%ones(length(charPSD),1); reject LH_32
                  ones(length(charPSD),1);  
                  %2.*ones(length(charPSD),1); reject RH_C3 
                  2.*ones(length(charPSD),1);
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  3.*ones(length(charPSD),1); 
                  4.*ones(length(charPSD),1);
                  4.*ones(length(charPSD),1);
                  %2.*ones(length(charPSD),1)reject RH_FC1
                  ];
          
    charPSD = [%charPSD(:,1); reject LH_32
               charPSD(:,2);
               %charPSD(:,3); reject RH_C3
               charPSD(:,4);
               charPSD(:,5);
               charPSD(:,6);
               charPSD(:,7);
               charPSD(:,8);
               charPSD(:,9);
               charPSD(:,10);
               %charPSD(:,11)reject RH_FC1
               ];

    minPSD = [%minPSD(:,1); reject LH_32
              minPSD(:,2);
              %minPSD(:,3); reject RH_C3
              minPSD(:,4);
              minPSD(:,5);
              minPSD(:,6);
              minPSD(:,7);
              minPSD(:,8);
              minPSD(:,9);
              minPSD(:,10);
              %minPSD(:,11)reject RH_FC1
              ];

    minfreq = [%minfreq(:,1); reject LH_32
               minfreq(:,2);
               %minfreq(:,3); reject RH_C3
               minfreq(:,4);
               minfreq(:,5);
               minfreq(:,6);
               minfreq(:,7);
               minfreq(:,8);
               minfreq(:,9);
               minfreq(:,10);
               %minfreq(:,11)reject RH_FC1
               ];        

    meanPSD = [%meanPSD(:,1); reject LH_32
               meanPSD(:,2);
               %meanPSD(:,3); reject RH_C3
               meanPSD(:,4);
               meanPSD(:,5);
               meanPSD(:,6);
               meanPSD(:,7);
               meanPSD(:,8);
               meanPSD(:,9);
               meanPSD(:,10);
              % meanPSD(:,11)reject RH_FC1
              ];
    
elseif strcmp(subj,'NC') == 1
    
    test_state = [ones(length(charPSD),1); 
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

%% Create test data features matrix
test_data = [charPSD, minPSD, minfreq, meanPSD];

%% Load training set and delete unneccessary variables
train_file = strcat('class_',subj,'.mat');
load(strcat('E:\McCann-Robot_hand\Matlab Code\EEG\EEG_Matt\',subj,'\offline\EEG\',train_file));

clearvars -except test* classification train*

%% Manipulate into useful variables
test_state = classification(:,end);
train_data = classification(:,1:end-1);

%% Use LDA_dwin.m to classify
% Training Data
W = LDA_dwin(train_data,test_state);
L = [ones(length(train_data),1) train_data] * W';
P = exp(L) ./ repmat(sum(exp(L),2),[1,4]);
[l,w] = size(P);
for m = 1:l
    for n = 1:w
        if (P(m,n) >=0.5)
            P(m,n) = 1;
        else
            P(m,n) = 0;
        end
    end
end

%Test Data
L_test = [ones(length(test_data),1) test_data] * W';
P_test = exp(L_test) ./ repmat(sum(exp(L_test),2),[1,4]);
[y,z] = size(P_test);
for o = 1:y
    for p = 1:z
        if (P_test(o,p) <= 0.2)
            P_test(o,p) = 0;
        elseif (P_test(o,p) >= 0.7)
            P_test(o,p) = 1;
        end
    end
end

%% Classification Accuracy
% Seperate state vector into variables to stats
state1 = find(mean_state == 1);    % LH
notstate1 = find(mean_state ~= 1); % LH
state2 = find(mean_state == 2);    % RH
notstate2 = find(mean_state ~= 2); % RH
state3 =  find(mean_state == 3);   % BH
notstate3 = find(mean_state ~= 3); % BH  
state4 =  find(mean_state == 4);   % F
notstate4 = find(mean_state ~= 4); % F

% Find false positive, false negative, true positive, and true negative rates
[FPR, FNR, TPR, TNR] = class_acc(P_test,state1,notstate1,state2,notstate2,state3,notstate3,state4,notstate4);


%% Create plots for visual analysis of classification
% Plot four row subplot. First three rows are state probabilities, fourth
% row is actual state.

% State Labels
states = ['Left Hand Imagery ','Right Hand Imagery';'Both Hands Imagery';'Feet Imagery      ']; 
statelabels = cellstr(states);

% Training data
figure()
for h = 1:size(P,2)
   subplot(5,1,h),plot(P(:,h))
   title(statelabels(h));
   if h == 3, ylabel('Probability of Belonging to this Class'), end
end
    subplot(5,1,5),plot(test_state,'r')
    title('Actual States')
    xlabel('Bin Number')

% Test data    
figure()
for l = 1:size(P_test,2)
   subplot(5,1,l),plot(P_test(:,l)) 
   title(statelabels(l));
   if l == 3, ylabel('Probability of Belonging to this Class'), end
end
    subplot(5,1,5),plot(test_state,'r')
    title('Actual States')
    xlabel('Bin Number')    