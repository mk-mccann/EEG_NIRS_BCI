function [param, sig, target, result] = load_online_EEG()
%% load_online_EEG.m
% Matthew McCann  
% 23 July 2015

% This file loads online EEG data from a matlab array found in a specific
% directory. EEG data is loaded into a matrix with each channel
% corresponding to a row. Parameter and state data are loaded so
% information relevant to the experiment can be extracted in subsequent
% scripts. The subject will  be drawn from the script calling this function
% as an input.

% Last Updated: 22 July, 2015
% Changelog
%   23/7/2015: Updated file path to load EEG files.

%% Choose file of interest 
% It is assumed that the file of interest is coming from the directory 
% listed in the EEGfile variable. This must be adjusted for new file 
% locations. The format of the input for the file variable must be 
% (NIRS/NIRX)\(~\raw)_subj_number.mat

global direc subj
file = input('Which EEG file would you like to load? ', 's');

EEGfile = load(strcat(direc,'Subject_Data\',subj,'\online\EEG\',file));
param = EEGfile.parameters;
sig = EEGfile.signal;
sig = sig;
target = EEGfile.states.TargetCode;
result = EEGfile.states.ResultCode;

end

