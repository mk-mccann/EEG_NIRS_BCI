function [classification, state] = make_classifier(subj, meanPSD_tEEG, charPSD_tEEG, minPSD_tEEG, minfreq_tEEG,...
                                                         meanPSD, charPSD, minPSD, minfreq,...
                                                         var_HbO, slope, deriv2)
%% make_classifier.m
% Matthew McCann
% 6 July, 2015

% Inputs: EEG features matrices - meanPSD, charPSD, minPSD, minfreq
%         NIRX features matrices - var_HbO, slope, deriv2
% Outputs: classification matrix, state vector

% NOTE: Subject-dependent channel elimination is necessary. This is
% accomplished in other functions such as EEG_setup.m and NIRS_setup.m.
% Within this function, the state variable must be changed if imagery states
% are eliminated.

% Last Updated: 27 July, 2015
% Changelog
%   27/7/2015: Updated SC cases to include LH imagery

%% State ------------------------------------------------------------------
oneslength = length(slope);

switch subj
    case 'JK'
        state = [%ones(oneslength,1); % LH imagery
                 %ones(oneslength,1); % LH imagery
                 %ones(oneslength,1); % LH imagery
              2.*ones(oneslength,1); % RH imagery
              2.*ones(oneslength,1); % RH imagery
              %2.*ones(oneslength,1); % RH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery              
              4.*ones(oneslength,1); % F  imagery
              4.*ones(oneslength,1)  % F  imagery
                ];
    case 'MRA'
        state = [%ones(oneslength,1); % LH imagery
                 %ones(oneslength,1); % LH imagery
                 %ones(oneslength,1); % LH imagery
              2.*ones(oneslength,1); % RH imagery
              2.*ones(oneslength,1); % RH imagery
              %2.*ones(oneslength,1); % RH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery              
              4.*ones(oneslength,1); % F  imagery
              4.*ones(oneslength,1)  % F  imagery
                ];
    case 'NC'
        state = [%ones(oneslength,1); % LH imagery
                 %ones(oneslength,1); % LH imagery
                 %ones(oneslength,1); % LH imagery
              2.*ones(oneslength,1); % RH imagery
              2.*ones(oneslength,1); % RH imagery
              %2.*ones(oneslength,1); % RH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery              
              4.*ones(oneslength,1); % F  imagery
              4.*ones(oneslength,1)  % F  imagery
                ];
    case 'SC'
        state = [ones(oneslength,1); % LH imagery
                 ones(oneslength,1); % LH imagery
                 %ones(oneslength,1); % LH imagery
              2.*ones(oneslength,1); % RH imagery
              2.*ones(oneslength,1); % RH imagery
              %2.*ones(oneslength,1); % RH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery
              %3.*ones(oneslength,1); % BH imagery              
              4.*ones(oneslength,1); % F  imagery
              4.*ones(oneslength,1)  % F  imagery
                ];            
end        

%% Convert features matrices into a single column matrix
% tEEG ---------------------------------------------------------------------
% The reshape function converts the features matrices to the following
% format. 
        % charPSD = [charPSD(:,1); % RH
        %            charPSD(:,2); % RH
        %            charPSD(:,3); % BH 
        %            charPSD(:,4); % BH
        %            charPSD(:,5); % BH 
        %            charPSD(:,6); % BH         
        %            charPSD(:,7); % F
        %            charPSD(:,8)  % F
        %            ];

    charPSD_tEEG = reshape(charPSD_tEEG, numel(charPSD_tEEG),1);        
    minPSD_tEEG = reshape(minPSD_tEEG, numel(minPSD_tEEG),1);
    minfreq_tEEG = reshape(minfreq_tEEG, numel(minfreq_tEEG),1);       
    meanPSD_tEEG = reshape(meanPSD_tEEG, numel(meanPSD_tEEG),1);   
    
% EEG ---------------------------------------------------------------------    

    charPSD = reshape(charPSD, numel(charPSD),1);        
    minPSD = reshape(minPSD, numel(minPSD),1);
    minfreq = reshape(minfreq, numel(minfreq),1);       
    meanPSD = reshape(meanPSD, numel(meanPSD),1);  
           
% NIRX --------------------------------------------------------------------
% See function NIRX_setup.m for specific subject channel breakdown.
% The two columns for each imagery state are converted to a single column
% vector, and combined into a larger column vector 

% The reshape function converts the features matrices to the following
% format. 
        % slope = [slope(:,1); % RH
        %          slope(:,2); % RH
        %          slope(:,3); % BH 
        %          slope(:,4); % BH
        %          slope(:,5); % BH 
        %          slope(:,6); % BH         
        %          slope(:,7); % F
        %          slope(:,8)  % F
        %          ];

    slope = reshape(slope, numel(slope), 1);
    deriv2 = reshape(deriv2, numel(deriv2), 1); 
    var_HbO = reshape(var_HbO, numel(var_HbO), 1); 

%% Make features matrix for classification

classification = [meanPSD_tEEG, minPSD_tEEG, minfreq_tEEG, charPSD_tEEG,...
                  meanPSD, minPSD, minfreq, charPSD,...
                  var_HbO, slope, deriv2];

end