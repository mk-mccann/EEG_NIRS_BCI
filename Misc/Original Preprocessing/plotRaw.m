function [] = plotRaw(signal, states, labels)
%% plotRaw.m 
% Written by Grzegorz Know, 18 Oct. 2010. Taken from 
% http://de.mathworks.com/matlabcentral/newsreader/view_thread/294163
% Adapted by Matthew McCann, 17 June 2015

global t0 

% signal dimensions
[r,c] = size(signal);

% calculate shift
mi = min(signal, [], 2);
ma = max(signal, [], 2);
shift = cumsum([0; abs(ma(1:end-1))+abs(mi(2:end))]);
shift = repmat(shift,1,length(t0));

% plot EEG data
figure()
subplot(2,1,1), plot(t0, signal+shift);

% edit axes
set(gca,'ytick',mean(signal+shift,2),'yticklabel',labels);
grid on
ylim([mi(1) max(max(shift+signal))]);
xlabel('Time (s)')

% plot State data
subplot(2,1,2), plot(t0, states);
xlabel('Time (s)');

end

