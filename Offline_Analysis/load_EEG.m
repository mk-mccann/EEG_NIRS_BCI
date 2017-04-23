function [param, sig, state] = load_EEG(cond,subj)
%% load_EEG.m
% Matthew McCann  
% June 2015

% This file loads EEG data from a matlab array found in a specific
% directory. EEG data is loaded into a matrix with each channel
% corresponding to a row. Parameter and state data are loaded so
% information relevant to the experiment can be extracted in subsequent
% scripts. The subject will  be drawn from the script calling this function
% as a global variable.

% Last Updated: 22 July, 2015
% Changelog
%   22/7/2015: Updated file path to load EEG files.

%% Global Variables
global direc

%% Choose file of interest 
% It is assumed that the file of interest is coming from the directory 
% listed in the EEGfile variable. This must be adjusted for new file 
% locations. The format of the input for the file variable must be 
% (NIRS/NIRX)\(~\raw)_subj_number.mat

file = input('Which EEG file would you like to load? ', 's');

EEGfile = load(strcat(direc,subj,'\offline\EEG\',file));
param = EEGfile.parameters;
sig = EEGfile.signal;
sig = sig'; %Transpose column matrix of electrode data to rows matrix 

if strcmp(cond,'raw')
    state = EEGfile.states.StimulusCode;
elseif strcmp(cond,'clean')
    state = EEGfile.state;
end


end

