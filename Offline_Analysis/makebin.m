function [numbins,newsize,binedges] = makebin(dataLength,numEle,overlap)
%% makebin.m
% Matthew McCann 
% 1 July, 2015

% Inputs: Length of dataset, desired number of elements in each bin, amount
% of overlap in bins
% Outputs:number of columns of the new matrix needed to accomodate even bin 
% division of the data, and a vector defining the edges of the bins 

% Last Updated: 20 July, 2015

binlength = ceil(dataLength./(numEle)); % number of bins
newsize = binlength*numEle; % Length of vector needed for even number of bins

% Bin Vector
binedges = [0:overlap:newsize-numEle;
            numEle:overlap:newsize];

numbins = length(binedges);
end