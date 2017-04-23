function [filtered_data] = butter_filter(data,coeff_B,coeff_A)
%% butter_filter.m 
% Matthew McCann
% 27 July, 2015

% Filters EEG using butterworth filter with coefficients set up earlier in
% script

% Last updated: 27 July 2015
% Changelog:

filtered_data = filtfilt(coeff_B,coeff_A,data);

end

