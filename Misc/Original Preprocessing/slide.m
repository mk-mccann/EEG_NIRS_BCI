function box = slide(data,window)
%% Slide.m is a sliding window averager for smoothing the data

b = (1/window)*ones(1,window);
a = 1;
[r,c] = size(data);
box = zeros(r,c);

for i = 1:r
    box(i,:) = filter(b,a,data(i,:));
end