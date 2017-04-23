function filtData = BPF(coefs, data)
%% BPF.m
% This function runs a filter with the given supplied coefficients on each
% row the the given data, and return a matric of filtered data


% Check input size
[r,c] = size(data);
filtData = zeros(r,c);

for i  = 1:r
    filtData(i,:) = filter(coefs,data(i,:));
end

end