function [states] = bin_class(bin_data)
% bin_class.m
% Matthew McCann
% 31 July, 2015

% This function evaluates each imagery state classification after being
% thresholded. If 1/2 or more elements of a channel are classified as a
% true positive, that channel is considered a true positive for that bin.
% Conflicting classifications are allowed. If no channel satisfies the
% requirements, the bin is considered to be in rest state. 

% Last updated: 31/07/2015
% Changelog:

% *************************************************************************

[r,c] = size(bin_data);
states = zeros(1,c);

for i = 1:c
    numone = find(bin_data(:,i) == 1);
    howmany = numel(numone);
    if howmany >= 4
        states(i) = 1;
    end
end

