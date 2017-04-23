function [fig] = tracePlot(x,y,names,xaxis,yaxis)
%% tracePlot.m
%takes in x axis data, y axis data, the channel names, and xlabel and
%ylabel strings to produce a 5x1 subplot window
[R,C] = size(y);

    if (isempty(x) == 1)
        figure()
        for i = 1:R
           subplot(R,1,i), plot(y(i,:)) 
           title(names(i))
           if (i==floor(R/2)), ylabel(yaxis), end
           if (i==R), xlabel(xaxis), end
        end 
    else
        figure()
        for i = 1:R
           subplot(R,1,i), plot(x,y(i,:)) 
           title(names(i))
           if (i==floor(R/2)), ylabel(yaxis), end
           if (i==R), xlabel(xaxis), end
        end
    end 

end

