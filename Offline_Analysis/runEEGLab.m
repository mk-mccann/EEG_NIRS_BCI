%% runEEGLab.m - EEGlab preprocessing
% Matthew McCann
% June 2015

% This script uses EEGlab to preprocess selected EEG files with filters
% and artifact removal. The majority of this code was written by modifying
% the command history produced by using the EEGlab GUI.

% Last Updated: 22 July, 2015
% Changelog
%   22/7/2015: Added user input to specify if tEEG or EEG data is being
%   processed. Script will now automatically select only relevant channels.
%   Updated file path. (see line 61)

%% Initialize Workspace
clear all; clf; close all; clc;

%% Choose data, start EEGlab, load data
datatype = input('What type of file, .dat or Matlab array? ','s');
subj = input('Which subject? ', 's');
type = input('tEEG or EEG? ', 's');

switch datatype
    case '.dat'
        % Use if data is in .dat format
        file = input('Which EEG file would you like to load? ', 's');
        EEGfile = strcat('E:\McCann-Robot_hand\Matlab_Code\Subject_Data\',subj,'\offline\EEG\',file);
       
        % Start EEGlab
       [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
        
       % Load File
        EEG = pop_loadBCI2000(EEGfile, {'StimulusCode'});
    
    case 'array'
        % Use if data is in matlab variable
        [parameters, signal, state] = load_EEG('raw',subj);
        state = single(state);
        signal = [signal;state'];
        
        % Start EEGlab
       [ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
        
       % Load File
        EEG = pop_importdata('dataformat','array','nbchan',0,'data','signal','setname','__','srate',256,'pnts',0,'xmin',0); 
end

clc;
filename = input('Name this dataset: ','s');

%% Load EEG file

[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',filename,'gui','off'); 

%% If using matlab array, extract event data
if (strcmp(datatype,'array') == 1)
    EEG = pop_chanevent(EEG, 17,'edge','both','edgelen',0);
    clear signal;
end

%% Take channels 1-8
% Channels 1-8 correspond to all tEEG data. For standard EEG data, take
% channels 9-16.
if strcmp(type, 'tEEG')
    EEG = pop_select( EEG,'channel',[1:8] );
elseif strcmp(type, 'EEG')
    EEG = pop_select( EEG,'channel',[9:16] );
end

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off'); 

%% Add channel locations
EEG = pop_editset(EEG, 'chanlocs', 'E:\\McCann-Robot_hand\\Matlab_Code\\Subject_Data\\loc.ced');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% Filtering
% Notch filter @ 60Hz
EEG = pop_eegfiltnew(EEG, [], 60, 68, 1, [], 0);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

% LPF 
lowpass = 35;
EEG = pop_eegfiltnew(EEG, [], lowpass, 98, 0, [], 0);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

% HPF @ 5 Hz
highpass = 5;
EEG = pop_eegfiltnew(EEG, [], highpass, 424, true, [], 0);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );

%% Run sliding average filter
EEG = pop_firma(EEG, 'forder', 2);
EEG = eeg_checkset(EEG);

%% Run ICA
EEG = pop_runica(EEG, 'extended',1,'interupt','on');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset(EEG);

%% Automatic EOG removal using BSS algorithm
EEG = pop_autobsseog( EEG, [10], [1], 'sobi', {'eigratio', [1000000]}, 'eog_fd', {'range',[0  2]});
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = eeg_checkset( EEG );

eeglab redraw;

%% Extract processed data, cleanup workspace, save files to corret folder
signal = EEG.data; 
clearvars -except signal parameters state subj

savefile = input('Save file as: ', 's');

save(strcat('E:\McCann-Robot_hand\Matlab_Code\Subject_Data\',subj,'\offline\EEG\NIRX\',savefile))