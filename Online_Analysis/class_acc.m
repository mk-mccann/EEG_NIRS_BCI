function [false_pos, false_neg, true_pos, true_neg] = class_acc(data, state1, not_state1, state2, not_state2, state3, not_state3, state4, not_state4)
%% class_acc.m
% Matthew McCann
% 14 July, 2015

% Calculates the false positive, false negative, true positive, and true
% negative rates as a percentage. See EEG_NIRS_learn.m for class labels.
% Note: not yet implemented in Online_Classifier.m

% Last Updated: 20 July, 2015


%% False Positives Rate
    % False Positives
    fp_1 = numel(find(data(not_state1,1) == 1));
    fp_2 = numel(find(data(not_state2,2) == 1));
    fp_3 = numel(find(data(not_state3,3) == 1));

    % False positives rate
    fpr_1 = fp_1/length(not_state1);
    fpr_2 = fp_2/length(not_state2);
    fpr_3 = fp_3/length(not_state3);

%% False Negatives Rate    
    % False negatives
    fn_1 = numel(find(data(state1,1) == 0));
    fn_2 = numel(find(data(state2,2) == 0));
    fn_3 = numel(find(data(state3,3) == 0));

    % False negatives rate
    fnr_1 = fn_1/length(state1);
    fnr_2 = fn_2/length(state2);
    fnr_3 = fn_3/length(state3);

    
%% True Positives Rate
    % True positivies 
    tp_1 = numel(find(data(state1,1) == 1));
    tp_2 = numel(find(data(state2,2) == 1));
    tp_3 = numel(find(data(state3,3) == 1));

    % True Positives Rate
    tp_1 = tp_1./length(state1);
    tp_2 = tp_2./length(state2);
    tp_3 = tp_3./length(state3);

%% True Negatives Rate    
    % True Negatives
    tn_1 = numel(find(data(not_state1,1) == 0));
    tn_2 = numel(find(data(not_state2,2) == 0));
    tn_3 = numel(find(data(not_state3,3) == 0));

    % True Negatives Rate
    tn_1 = tn_1./length(not_state1);
    tn_2 = tn_2./length(not_state2);
    tn_3 = tn_3./length(not_state3);  

%% Change depending on number if inputs    
if nargin == 7    
    % False Poitives Rate
        false_pos = [fpr_1, fpr_2, fpr_3].*100;
    % False Negatives Rate    
        false_neg = [fnr_1, fnr_2, fnr_3].*100;    
    % True Positives Rate
        true_pos = [tp_1, tp_2, tp_3].*100;
    % True Negatives Rate
        true_neg = [tn_1, tn_2, tn_3].*100;  
    
elseif nargin == 9
    % False Positives Rate    
        fp_4 = numel(find(data(not_state4,4) == 1));
        fpr_4 = fp_4/length(not_state4);
        false_pos = [fpr_1, fpr_2, fpr_3, fpr_4].*100;
    % False Negatives Rate
        fn_4 = numel(find(data(state4,4) == 0));
        fnr_4 = fn_4/length(state4);
        false_neg = [fnr_1, fnr_2, fnr_3, fnr_4].*100;  
    % True Positives Rate
        tp_4 = numel(find(data(state4,4) == 1));
        tp_4 = tp_4./length(state4);
        true_pos = [tp_1, tp_2, tp_3, tp_4].*100;        
    % True Negatives Rate
        tn_4 = numel(find(data(not_state4,4) == 0));
        tn_4 = tn_4./length(not_state4);  
        true_neg = [tn_1, tn_2, tn_3, tn_4].*100;  
     
end
end

