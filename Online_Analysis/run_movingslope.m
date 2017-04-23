function slope = run_movingslope(data,windowlength,order,dt)
%% run_movingslope.n
% Matthew Mccann 
% Last Updated: 20 July, 2015

% Inputs: NIRS data matrix, size of window over which slope is calculated,
% regression order, time step of data matrix
% Outpts: matrix of slope vlaues by channel for NIRS data

[r,c] = size(data);
slope = zeros(r,c);

for i = 1:c
    slope(:,i) = movingslope(data(:,i),windowlength,order,dt);
end

end

