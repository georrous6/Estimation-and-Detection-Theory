function [cleanIntervals, noisyIntervals, max_window_size, idx] = find_intervals(x, N)
    
    % Step 1: Group noisy indices into contiguous intervals
    d = diff(x);
    splitPoints = [0, find(d > 1), length(x)];
    
    noisyIntervals = cell(1, length(splitPoints)-1);
    for i = 1:length(noisyIntervals)
        range = x(splitPoints(i)+1 : splitPoints(i+1));
        noisyIntervals{i} = [range(1), range(end)];
    end
    
    % Step 2: Infer clean intervals from gaps between noisy intervals
    cleanIntervals = {};
    prevEnd = 0;
    for i = 1:length(noisyIntervals)
        startIdx = noisyIntervals{i}(1);
        if prevEnd + 1 < startIdx
            cleanIntervals{end+1} = [prevEnd + 1, startIdx - 1];
        end
        prevEnd = noisyIntervals{i}(2);
    end
    if prevEnd < N
        cleanIntervals{end+1} = [prevEnd + 1, N];
    end
    
    % Step 3: Combine all intervals and compute lengths
    allIntervals = [noisyIntervals, cleanIntervals];
    lengths = cellfun(@(r) r(2) - r(1) + 1, allIntervals);
    
    % Step 4: Find the smallest interval and the start of it
    [max_window_size, minIdx] = min(lengths);
    idx = allIntervals{minIdx}(1);  % Start of the smallest interval

end