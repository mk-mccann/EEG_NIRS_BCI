function [classification] = make_online_classifier(meanPSD_tEEG, charPSD_tEEG, minPSD_tEEG, minfreq_tEEG,...                                                   
                                                   var_HbO, slope, deriv2, ...
                                                   meanPSD, charPSD, minPSD, minfreq)
%% make_online_classifier.m
% Matthew McCann
% 22 July, 2015


% Inputs: EEG features matrices - meanPSD, charPSD, minPSD, minfreq
%         NIRX features matrices - var_HbO, slope, deriv2
% Outputs: classification matrix

% NOTE: Subject-dependent channel elimination is necessary. This is
% accomplished in other functions such as EEG_setup.m and NIRS_setup.m.
% Within this function, the state variable must be changed if channels are 
% eliminated.

% Last Updated: 28 July, 2015
% Changelog
%   28/7/2015: Rearranged code to accept EEG inputs as optional, and to
%   build classifier including EEG components

%% Convert features matrices into a single column matrix

% tEEG ---------------------------------------------------------------------
% The reshape function converts the features matrices to the following
% format. 
        % charPSD = [charPSD(:,1);  % LH
        %            charPSD(:,2);  % LH
        %            charPSD(:,3);  % RH 
        %            charPSD(:,4);  % RH         
        %            charPSD(:,5);  % BH 
        %            charPSD(:,6);  % BH
        %            charPSD(:,7);  % BH 
        %            charPSD(:,8);  % BH         
        %            charPSD(:,9);  % F
        %            charPSD(:,10)  % F
        %            ];

    charPSD_tEEG = reshape(charPSD_tEEG, numel(charPSD_tEEG),1);        
    minPSD_tEEG = reshape(minPSD_tEEG, numel(minPSD_tEEG),1);
    minfreq_tEEG = reshape(minfreq_tEEG, numel(minfreq_tEEG),1);       
    meanPSD_tEEG = reshape(meanPSD_tEEG, numel(meanPSD_tEEG),1);   
           
% NIRX --------------------------------------------------------------------
% See function NIRX_setup.m for specific subject channel breakdown.
% The two columns for each imagery state are converted to a single column
% vector, and combined into a larger column vector 

% The reshape function converts the features matrices to the following
% format. 
        % slope = [slope(:,1);  % LH
        %          slope(:,2);  % LH
        %          slope(:,3);  % RH 
        %          slope(:,4);  % RH         
        %          slope(:,5);  % BH 
        %          slope(:,6);  % BH
        %          slope(:,7);  % BH 
        %          slope(:,8);  % BH         
        %          slope(:,9);  % F
        %          slope(:,10)  % F
        %          ];

    slope = reshape(slope, numel(slope), 1);
    deriv2 = reshape(deriv2, numel(deriv2), 1); 
    var_HbO = reshape(var_HbO, numel(var_HbO), 1); 
    
        % Make features matrix for classification
        classification = [meanPSD_tEEG, minPSD_tEEG, minfreq_tEEG, charPSD_tEEG,...
                          var_HbO, slope, deriv2];

% EEG ---------------------------------------------------------------------        
    if nargin > 7
        charPSD = reshape(charPSD, numel(charPSD),1);        
        minPSD = reshape(minPSD, numel(minPSD),1);
        minfreq = reshape(minfreq, numel(minfreq),1);       
        meanPSD = reshape(meanPSD, numel(meanPSD),1);   
        
        % Make features matrix for classification
        classification = [meanPSD_tEEG, minPSD_tEEG, minfreq_tEEG, charPSD_tEEG,...
                  var_HbO, slope, deriv2,...
                  meanPSD, minPSD, minfreq, charPSD];
    end
    


end