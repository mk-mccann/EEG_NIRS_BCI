function [tEEG_charPSD,tEEG_meanPSD,tEEG_minPSD,tEEG_minfreq,...
          NIRS_var_HbO,NIRS_slope,NIRS_deriv2,...
          EEG_charPSD,EEG_meanPSD,EEG_minPSD,EEG_minfreq]...
        = get_features(tEEG_data, tEEG_intfreq, tEEG_charfreq, NIRS_data, EEG_data, EEG_intfreq, EEG_charfreq)

%% get_features.m
% Matthew McCann
% 27 July, 2015

% Extracts features in convenient function format so as to not clutter
% online script. Same process as the file EEG_NIRS_class.m contained in the
% Offline_Analysis folder.

% Last updated: 28 July 2015
% Changelog:
%   28/7/2015: Updated function to accept optional EEG inputs. Not all
%   datasets will have EEG recording, so this simplifies outputs for use
%   later

% Global Variables --------------------------------------------------------
    global Fs_EEG

% Get data size -----------------------------------------------------------
    [~,c] = size(tEEG_data);
    
% Preallocate matrices ----------------------------------------------------
    tEEG_charPSD = zeros(1,c);
    tEEG_meanPSD = zeros(1,c);
    tEEG_minPSD = zeros(1,c);
    tEEG_minfreq = zeros(1,c);
    
    EEG_charPSD = zeros(1,c);
    EEG_meanPSD = zeros(1,c);
    EEG_minPSD = zeros(1,c);
    EEG_minfreq = zeros(1,c);
    
    NIRS_var_HbO = zeros(1,c);
    NIRS_slope = zeros(1,c);
    NIRS_deriv2 = zeros(1,c); 
    
% Set up variables for using movingslope.m ********************************
slidingwindow = 3; % Three points for linear regression
order = 1;         % First order (linear) regression
dt = 1/Fs_EEG;     % Period is the time step.
% *************************************************************************       
    
for i = 1:c                               % Loop through columns (channels)      
% tEEG --------------------------------------------------------------------
    % Find PSD of bin, minimum PSD, and frequency at which min occurs
        [pxx,f] = periodogram(tEEG_data(:,i),[],tEEG_intfreq(i,:),Fs_EEG);
        tEEG_charPSD(i) = pxx(f == tEEG_charfreq(i));
        tEEG_meanPSD(i) = mean(pxx); 
        small = min(pxx);
        tEEG_minPSD(i)  = small(1);
        smallfreq = f(pxx == tEEG_minPSD(i));
        tEEG_minfreq(i) = smallfreq(1);                   

% NIRX --------------------------------------------------------------------              
    % Find HbO variance     
         NIRS_var_HbO(i) = var(NIRS_data(:,i));
    % Find d[HbO]/dt 
        slope = movingslope(NIRS_data(:,i),slidingwindow,order,dt);
        NIRS_slope(i) = mean(slope);
    % Find d2[HbO]/dt2    
        slope_slope = movingslope(slope,slidingwindow,order,dt);
        NIRS_deriv2(i) = mean(slope_slope);
    
    if nargin > 4
    % EEG ---------------------------------------------------------------------
        % Find PSD of bin, minimum PSD, and frequency at which min occurs
            [pxx,f] = periodogram(EEG_data(:,i),[],EEG_intfreq(i,:),Fs_EEG);
            EEG_charPSD(i) = pxx(f == EEG_charfreq(i));
            EEG_meanPSD(i) = mean(pxx);    
            EEG_minPSD(i)  = min(pxx);
            EEG_minfreq(i) = f(pxx == EEG_minPSD(i));    
    end
end

end

