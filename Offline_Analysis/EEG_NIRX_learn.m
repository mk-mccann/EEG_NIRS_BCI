%% EEG_NIRX_learn.m
% Matthew McCann
% 10 July, 2015

% Uses LDA.m to classify offline EEG/NIRX data. Imposes probability cutoffs
% with hysteresis, where values < 0.4 go to 0 and values > 0.6 go to 1.
% Probabilities falling between these cutoffs are evaluated observation by
% observation, with the state having the highest probability designated a
% the ral state (sent to 1) and all other states sent to 0.

% Last Updated: 23 July, 2015
% Changelog
%   22/7/2015: Imposed hystersis cutoffs of 0.4 and 0.6, and wrote logic to
%   evaluate values between those cutoffs. The most probable state is made
%   the actual state. Updated file path name for loading training and
%   testing datasets. 
%   23/7/2015: Added code to create test data and test state matrices by
%   randomly sampling 15% of the classifier matrix, removing those
%   observations from the classifier matrix, and training with the
%   remaining 85% of classifiers


%% Initialize Workspace
clear;clf;close all;clc;

%% Load classifier Matrix
subj =input('Which subject? ','s');
load(strcat('E:\McCann-Robot_hand\Matlab_Code\EEG_NIRX_classifiers\',subj,'_EEG_NIRX_classifier'));

% Combine data and states
data = [classifier, state];

% Seperate a random 15 of data matrix for test dataset
[t_mat, rows] = datasample(data, 0.2*length(data));

% Sort testing data by state
sort_data = sortrows(t_mat, size(t_mat, 2)); % Sort according to state variable
test_data = sort_data(:,1:end-1);
test_state = sort_data(:,end);

% Remove 15% from original matrix and seperate into training data
data(rows,:) = [];
train_data = data(:,1:end-1);
train_state = data(:,end);

clearvars classifier state sort*
%% Load Test Data
% load(strcat('E:\McCann-Robot_hand\Matlab_Code\EEG_NIRX_classifiers\',subj,'_test_EEG_NIRX_classifier'));
% 
% test_data = classifier;
% test_state = state;
% 
% clearvars classifier state

%% Build training set
% Training Data
% See LDA.m function for details on each of these variables
W = LDA(train_data,train_state);

L = [ones(length(test_data),1) test_data] * W';
P = exp(L) ./ repmat(sum(exp(L),2),[1,3]);

%% Improve classification with thresholds
% Since the subjects used have minimal training, a probability of 0.45 is
% taken as a true imagery classification. With training, this threshold
% will improve. While more complex, the threshold are broken up by subject
% in the switch structure for easy addition of more subjects, since each
% may have a different significance threshold or channel rejection scheme. 

[l,w] = size(P);

switch subj
    case 'MRA' % ----------------------------------------------------------
        % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (P(o,p) < 0.4)
                    P(o,p) = 0;
                elseif (P(o,p) >= 0.6)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(P(o,:));
                    column = find(P(o,:) == max_prob);
                    not_column = find(P(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end
       
        % Define State Conditions - Eliminate LH Imagery
        states = ['Right Hand Imagery';'Both Hands Imagery';'Feet Imagery      ']; 

    case 'JK' % -----------------------------------------------------------
        % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (P(o,p) < 0.4)
                    P(o,p) = 0;
                elseif (P(o,p) >= 0.6)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(P(o,:));
                    column = find(P(o,:) == max_prob);
                    not_column = find(P(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end
        
        % Define State Conditions - Eliminate LH Imagery
        states = ['Right Hand Imagery';'Both Hands Imagery';'Feet Imagery      ']; 
        
    case 'NC' % -----------------------------------------------------------
       % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (P(o,p) < 0.4)
                    P(o,p) = 0;
                elseif (P(o,p) >= 0.6)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(P(o,:));
                    column = find(P(o,:) == max_prob);
                    not_column = find(P(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end
        
        % Define State Conditions - Eliminate LH Imagery
        states = ['Right Hand Imagery';'Both Hands Imagery';'Feet Imagery      '];
        
    case 'SC' % -----------------------------------------------------------
       % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (P(o,p) < 0.4)
                    P(o,p) = 0;
                elseif (P(o,p) >= 0.6)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(P(o,:));
                    column = find(P(o,:) == max_prob);
                    not_column = find(P(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end
        
        % Define State Conditions - Eliminate LH Imagery
        states = ['Right Hand Imagery';'Both Hands Imagery';'Feet Imagery      '];        

end

%% Bin into 1 second increments
% One second increments are generated by averaging data from the orignal 9
% samples per second. This will smooth the motion of the hand and prevent
% the script from running too slowly.

% Define binning parameters *******************************************
numEle = 10;                  % Number of elements in each bin 
overlap = floor(numEle.*0.5); % Bins overlap by 50%
% *********************************************************************

% Make bins
[numbins,~,binedges] = makebin(l,numEle,overlap);

% Adjust bin edges if data length is shorter than makebin.m expects
[r_end,c_end] = find(binedges >= l);
binedges(:,c_end(1)+1:end) = [];
binedges(end,end) = l;
numbins = length(binedges);

% Bins to hold class and state data
binClass = zeros(numEle,w); 
class = binClass; 
binState = zeros(numEle,1);
state = binState;

% Predefine empty matrices to hold classification
    % Define matrix to hold mean class
    P_test = zeros(numbins-1,w);
    % Define matrix to hold mean state
    mean_state = zeros(numbins-1,1);

% Set up first bins
for a = 1:w
    class(:,a) = P((binedges(1,1)+1):binedges(2,1),a);
end
    state = test_state((binedges(1,1)+1):binedges(2,1));

%% Take data in 1 second intervals and average
for b = 2:numbins
   binsize = length(binedges(1,b)+1:binedges(2,b));

   % State information ----------------------------------------------------
   binState(1:binsize) = test_state((binedges(1,b)+1):binedges(2,b));
   mean_state(b-1) = mean(state);
       
   % Class information ----------------------------------------------------
    for m = 1:w
        % Collect new data/define new bin for state -----------------------
        binClass(1:binsize,m) = P((binedges(1,b)+1):binedges(2,b),m);
        
        % New classificiation
        P_test(b-1,m) = mean(class(:,m));
    end
        
    % Redefine bins -------------------------------------------------------
    state = binState;
    class = binClass;

end

%% Again set threshold
% Since P_test is a asmpling of the biary state matrix P, a 0.45 threshold
% is appropriate here. The data has already been assigned to a class, now
% this section assigns the entire 1-second interval to an appropriate
% imagery state

[r,c] = size(P_test);

for d = 1:r
    for f = 1:c
        if (P_test(d,f) < 0.45)
            P_test(d,f) = 0;
          elseif (P_test(d,f) >= 0.45)
              P_test(d,f) = 1;
        end
    end
end

% At the edges of the state variable, a nin-integer state value may arise.
% In these cases, round up or down to the next state.
for f = 1:length(mean_state)
    if mean_state(f) < floor(mean_state(f)+0.5)
        mean_state(f) = floor(mean_state(f));
    else
        mean_state(f) = ceil(mean_state(f));
    end
end

%% Classification Accuracy
% Seperate state vector into variables to stats
state1 = find(mean_state == 2);    % RH
notstate1 = find(mean_state ~= 2); % RH
state2 = find(mean_state == 3);    % BH
notstate2 = find(mean_state ~= 3); % BH
state3 =  find(mean_state == 4);   % F
notstate3 = find(mean_state ~= 4); % F  
% Uncomment if all 4 states are used
%         state4 =  find(mean_state == 4); 
%         notstate4 = find(mean_state ~= 4); 

% Find false positive, false negative, true positive, and true negative rates
[FPR, FNR, TPR, TNR] = class_acc(P_test,state1,notstate1,state2,notstate2,state3,notstate3)

%% Plots for visual analysis
% Plot four row subplot. First three rows are state probabilities, fourth
% row is actual state.

statelabels = cellstr(states);

% % original state
figure()
title('Classification vs. Known Class')
for g = 1:size(P,2)
    subplot(size(P,2)+1,1,g), plot(P(:,g),'b.')
    title(statelabels(g));
    if g == 3, ylabel('Probability of Belonging to this Class'), end
end
subplot(size(P_test,2)+1,1,g+1), plot(mean_state,'r.')
title('Actual States')
xlabel('Bin Number')

% 1-second increments
figure()
title('Classification vs. Known Class')
for h = 1:size(P_test,2)
    subplot(size(P_test,2)+1,1,h), plot(P_test(:,h),'b.')
    title(statelabels(h));
    if h == 3, ylabel('Probability of Belonging to this Class'), end
end
subplot(size(P_test,2)+1,1,h+1), plot(mean_state,'r.')
title('Actual States')
xlabel('Bin Number')

% 
% figure()
% title('Classification vs. Known Class')
% for h = 1:size(P_test,2)
%     subplot(size(P_test,2)+1,1,h), plot(P_test(1500:3000,h),'b.')
%     title(statelabels(h));
%     if h == 3, ylabel('Probability of Belonging to this Class'), end
% end
% subplot(size(P_test,2)+1,1,h+1), plot(mean_state(1500:3000),'r.')
% title('Actual States')
% xlabel('Bin Number')
%% Housekeeping
 clearvars -except train* P* T* F* mean*

%% Hand Control 
 
% Setup Serial Connection
% global S
% S = serial('COM6');
% set(S, 'Terminator', 'CR/LF');
% set(S, 'BaudRate', 9600, 'DataBits',8,'Parity','none','StopBits',1);
% fopen(S);
% 
% it_moves(P_test(1500:3000,:));
% 
% %% Close Serial Connection
% fclose(S)