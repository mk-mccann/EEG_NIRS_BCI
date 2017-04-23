function [P] = set_threshold(classified)
% reclass.m
% Matthew McCann
% 29 July, 2015

% This function takes classified data, assigns 

% Last Updated 29 July, 2015
% Changelog

global subj

[l,w] = size(classified);
P = zeros(l,w);

switch subj
    case 'MRA' % ----------------------------------------------------------
        % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (classified(o,p) < 0.4)
                    P(o,p) = 0;
                elseif (classified(o,p) >= 0.6)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(classified(o,:));
                    column = find(classified(o,:) == max_prob);
                    not_column = find(classified(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end

    case 'JK' % -----------------------------------------------------------
        % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (classified(o,p) < 0.4)
                    P(o,p) = 0;
                elseif (classified(o,p) >= 0.6)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(classified(o,:));
                    column = find(classified(o,:) == max_prob);
                    not_column = find(classified(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end

        
    case 'NC' % -----------------------------------------------------------
       % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (classified(o,p) < 0.4)
                    P(o,p) = 0;
                elseif (classified(o,p) >= 0.6)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(classified(o,:));
                    column = find(classified(o,:) == max_prob);
                    not_column = find(classified(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end

        
    case 'SC' % -----------------------------------------------------------
       % Set significance threshold
        for o = 1:l
            for p = 1:w
                if (classified(o,p) < 0.3)
                    P(o,p) = 0;
                elseif (classified(o,p) >= 0.5)
                    P(o,p) = 1;
                else
                    % Find likeliest channel
                    max_prob = max(classified(o,:));
                    column = find(classified(o,:) == max_prob);
                    not_column = find(classified(o,:) ~= max_prob);
                    P(o,column) = 1;
                    P(o, not_column) = 0;
                end
            end
        end
  

end


end

