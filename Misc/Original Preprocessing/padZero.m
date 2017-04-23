function [newData,Rnew,Cnew,tnew] = padZero(R,C,data)
%% padZero.m
% Pad a matrix with zeros. R and C are the dimensions of the new padded
% matrix, and data is the original data.

global Fs

newData = zeros(R,C);
[r,c] = size(data);
for i = 1:r
    for j = 1:c
        newData(i,j) = data(i,j);
    end
end

[Rnew,Cnew] = size(newData);
    
% Redefine time vector
tnew = (0:Cnew-1)/Fs; %Time in seconds

% Clear old data
clear data
end

