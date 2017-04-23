%% OnlineAnalysis.m
% This script will load an online file of interest, seperate it into the
% channels of interest, and run a large for loop that bins and analyzes the
% data

%% Initialize Workspace and Import Files
clear all; clf; close all; clc

% NIRS

% EEG
[parameters, raw, states] = loadfile('EEG');

%% Collect NIRS Raw Signal
% [rnirs, cnirs] = size(NIRS_data)

%% Collect EEG Raw Signal
global R C Fs t0 channelNames 

[R,C] = size(raw); % C is the number of samples, R is the channel
channelNames = parameters.ChannelNames.Value(:); %Channel names will be the same for each trial
clear file i init k s signal states

% Sampling rate, Period, and Total Acquisition Time
Fs = parameters.SamplingRate.NumericValue; %Get sampling frequency (Hz)
t0 = (0:C-1)./Fs; %Time in seconds
clear parameters

%% Define binning parameters and set up empty binning matrices
%EEG
seconds = 1; % Duration of each bin
numEle_EEG = seconds*Fs; % Number of elements in each bin (256 sample/sec for timing)
overlap = 100; % Amount of overlap in each bin
[numbins,changesize,binedges] = makebin(numEle_EEG);
binEEG = zeros(R,numEle_EEG); %Create zeros matrix to accomodate a bin for each channel
EEG = binEEG; % Create a matrix to house the different EEG channels in different rows

%NIRS testing
numEle_NIRS = numEle_EEG;
binNIRS = zeros(R,numEle_NIRS); % Create a matrix to accomodate a bin for NIRS data
NIRS = binNIRS; % Create a matrix to house the different NIRS channels in different rows

%% Pad with zeros 
% By binning the data, we are forced to either cut off the back end 
% of the dataset or pad the dataset with zeros. I opt to pad the dataset.

% EEG
global Rnew Cnew tnew
[rawEEG, Rnew, Cnew, tnew] = padZero(R,changesize,raw);
clear raw

% NIRS
% global Rnew_nirs Cnew_nirs tnew_nirs
% [rawBig, Rnirs, Cnirs, tnew] = padZero(rnirs,changesize,NIRS_data);
% clear NIRS_data

%% EEG Preprocessing

% Here an initial filter from 0 to 40 Hz is designed and implemented onthe
% entire EEG signal. The first bin is created, and a vector to hold maximum
% frequency values is initialized. 

        %BPF options - 0 - 40 Hz
        lowF = 1.5; %Hz
        highF = 40; %Hz
        stop1 = lowF-1; %Hz
        stop2 = highF+1; %Hz

        % Make filter
        bpf = buildFilt(stop1,lowF,highF,stop2);

        % Run Bandpass Filter
%         allFiltEEG = BPF(bpf,rawEEG);

        % Predefine First EEG Bin Channels
            % Note: channels are by row as follows: C3, C1, Cz, C2, C4
            for k = 1:Rnew
                EEG(k,:) = rawEEG(k,binedges(1)+1:binedges(2));
            end

        % Sliding window options
        time = 0.5; % Time duration for sliding window
        window = find(tnew==time); % number of elements in sliding window

        % Predefine matrix for maximum EEG frequencies from BPF, mu band, and beta band
        maxfreqBPF = zeros(Rnew,numbins);

% Create a filter that isolates the Mu band frequencies, and initialize a
% vector to hold the maximum frequencies within this band.

        % Mu Band Filter options - 8 - 12 Hz
        lowFmu = 8; %Hz
        highFmu = 12; %Hz
        stop1mu = lowFmu-1.5; %Hz
        stop2mu = highFmu+1.5; %Hz

        % Make filter
        mufilt = buildFilt(stop1mu,lowFmu,highFmu,stop2mu);

        % Initialize vector fox max frequencies within Mu band
        maxfreqMu = zeros(Rnew,numbins);

% Create a filter that isolates the Beta band frequencies, and initialize a
% vector to hold the maximum frequencies within this band.

        % Beta Band Filter options - 16 - 30 Hz
        lowFbeta = 16; %Hz
        highFbeta = 30; %Hz
        stop1beta = lowFbeta-1.5; %Hz
        stop2beta = highFbeta+1.5; %Hz

        % Make filter
        betafilt = buildFilt(stop1beta,lowFbeta,highFbeta,stop2beta);

        % Initialize vector fox max frequencies within Beta band
        maxfreqBeta = zeros(Rnew,numbins);

%% NIRS Preprocessing ***************************************
% Simulate NIRS data with random numbers
global Rnirs Cnirs
Rnirs = Rnew;
Cnirs = Cnew;
NIRS_sim = 10.*rand(Rnirs,Cnirs);

% Predefine first NIRS bin
for p = 1:Rnirs
    NIRS(p,:) = NIRS_sim(p,binedges(1)+1:binedges(2));
end









%% Giant loop that does everything
for l = 2:numbins
    %% Collect new data/define new bins
    for m = 1:Rnew
        binEEG(m,:) = rawEEG(m,binedges(l)-(overlap-1):binedges(l+1)-overlap);
        binNIRS(m,:) = NIRS_sim(m,binedges(l)+1:binedges(l+1));
    end
    
    %% NIRS Processing
    % Take average of NIRS data for bin
        NIRS_avg = mean(NIRS,2);
        check = (NIRS_avg >= 5);
   
    % Check to see if activity in relevant channels
        if ((check(1) == 1 || check(2) == 1) && (check(3) == 0 && check(4) == 0 && check(5)==0))
            area = 'right';
        elseif ((check(3) == 1) && (check(1) == 0 && check(2) == 0 && check(4) == 0 && check(5)==0))
            area = 'foot';
        elseif ((check(4) == 1 || check(5) == 1) && (check(1) == 0 && check(2) == 0 && check(3)==0));
            area = 'left';
        else
            area = 'none';
        end
    
    %% EEG Processing
    
    % Run initial filter  
        EEGfilt = BPF(bpf,EEG);
    
    % Check initial Bandpass region
        % Initial Spectral Analysis (Only BPF)
        [PSD_BPF, f_BPF] = powerspec(EEGfilt);
        % Use sliding window averager
        boxcar = slide(PSD_BPF, window);
        
    % Run data through mu and beta band filters, get power spectra, and run boxcar averager
        Mu = BPF(mufilt, EEGfilt);
        [PSD_Mu, f_Mu] = powerspec(Mu);
        muBox = slide(PSD_Mu, window);
        
        Beta = BPF(betafilt, EEGfilt);
        [PSD_beta, f_beta] = powerspec(Beta);
        betaBox = slide(PSD_beta, window);
    
    % Go to channels
    switch(area)
        case 'right'
        % Go to EEG to check channels C3 and C1 for activity
        %disp('Right')
            n = 1:2;
            maxfreq = getMaxFreq(PSD_BPF, f_BPF, n, 1);
            maxfreqBPF(n(1),l) = maxfreq(1);
            maxfreqBPF(n(2),l) = maxfreq(2);
                
        case 'foot'
        % Go to EEG to check channels Cz for activity
        %disp('Foot')
            n = 3;
            maxfreq = getMaxFreq(PSD_BPF, f_BPF, n, 1); 
            maxfreqBPF(n,l) = maxfreq;
            
        case 'left'
        % Go to EEG to check channels C2 and C4 for activity
        %disp('Left')
            n = 4:5;
            maxfreq = getMaxFreq(PSD_BPF, f_BPF, n, 1);
            maxfreqBPF(n(1),l) = maxfreq(1);
            maxfreqBPF(n(2),l) = maxfreq(2);
        
        case 'none'
        %disp('None')
                
    end
        
     %% Movement Control
     %Need series of IF statements to control hand based on analysis
     
%      if (conditions for right hand are true)
%         Control sequence for moving pinky finger
%         closepinky()
%      
%      elseif (conditions for left hand are true)
%         Control sequence for moving ring finger
%         
%      elseif (conditions for feet are true)
%         Control sequence for moving middle finger 
%         closemiddle()              
%         
%      else 
%         Control sequence for opening hand or keeping hand open
%      
%      end
        

    %% Redefine channels for next iteration
    for z = 1:Rnew
        EEG(z,:) = binEEG(z,:);
        NIRS(z,:) = binNIRS(z,:);
    end

end

%% Plots

% Original Signals
tracePlot(tnew,rawEEG,channelNames,'Time','Voltage (\muV)')

% Filtered Signals
% tracePlot(tnew,allFiltEEG,channelNames,'Time','Voltage (\muV)')

% Mamximum Frequency by Bin
tracePlot(1:numbins,maxfreqBPF,channelNames,'Bin Number','Max Frequency (Hz)')

% % Sliding window average
% allSlide = slide(allFiltEEG, 10000);
% tracePlot([],allSlide,channelNames,'Time','Voltage (\muV)');
