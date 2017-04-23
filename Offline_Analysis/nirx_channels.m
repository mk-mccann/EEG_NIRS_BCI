function [RH, LH, F, other] = nirx_channels(dataset)
%% nirx_channels.m
% Matthew McCann
% July, 2015

% This function takes the preprocessed NIRS data (processued using
% NIRSlab)and breaks it into matrix based on cortex location. The edited
% input dataset is a 20-column matrix where each column represents a 
% different channel.  

% Last Updated: 20 July, 2015

%% Break NRIX data into channels
    % C3_RH
        C5 = dataset(:,5);
        C6 = dataset(:,6);
        C9 = dataset(:,9);
        C10 = dataset(:,10);

        RH = [C5, C6, C9, C10]; % RH mat

    % Cz_F
        C1 = dataset(:,1);
        C2 = dataset(:,2);
        C11 = dataset(:,11);
        C12 = dataset(:,12);

        F = [C1, C2, C11, C12]; % Foot mat

    % C4_LH
        C15 = dataset(:,15);
        C16 = dataset(:,16);
        C19 = dataset(:,19);
        C20 = dataset(:,20);

        LH = [C15, C16, C19, C20]; % LH mat for set 1

    % Other
        C3 = dataset(:,3);
        C4 = dataset(:,4);
        C7 = dataset(:,7);
        C8 = dataset(:,8);
        C13 = dataset(:,13);
        C14 = dataset(:,14);
        C17 = dataset(:,17);
        C18 = dataset(:,18);
        
        other = [C3, C4, C7, C8, C13, C14, C17, C18];
end

