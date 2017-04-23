function maxfreq = getMaxFreq(dataMag,dataFreq, rows, reject)
%% getMaxFreq.m
% Find the maximum frequency information for each bin. User must enter the
% magnitude data set, the frequency vector, the rows if interest from the
% data set, and the minimum frequency (below which all values will be set
% to zero.

maxfreq = zeros(numel(rows),1);
if (numel(rows) >= 2)  
    for i = 1:numel(rows)
        maxmag = max(dataMag(rows(i),:));
        where = find(dataMag(rows(i),:) == maxmag);
        maxfreq(i) = dataFreq(where);
        if (maxfreq(i) <= reject), maxfreq(i) = 0; end
    end
elseif(numel(rows)==1)
    i = rows;
    maxmag = max(dataMag(i,:));
    where = find(dataMag(i,:) == maxmag);
    maxfreq = dataFreq(where);
    if (maxfreq <= reject), maxfreq = 0; end
end

end