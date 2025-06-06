function s = wiener_smoothing(eeg_data, blinks)
    eeg_data = eeg_data(:);
    N = length(eeg_data);
    [max_window_size, ~, cleanIntervals, noisyIntervals] = find_smallest_interval(blinks, N);

    R_xx = zeros(max_window_size, max_window_size);
    R_ss = zeros(max_window_size, max_window_size);
    for i = 1:length(cleanIntervals)
        data = eeg_data(cleanIntervals{i}(1):cleanIntervals{i}(2));
        data = data - mean(data);
        r_full = xcorr(data, max_window_size - 1, 'biased');
        R_ss = R_ss + toeplitz(r_full(max_window_size:end));
    end
    R_ss = R_ss ./ length(cleanIntervals);

    for i = 1:length(noisyIntervals)
        data = eeg_data(noisyIntervals{i}(1):noisyIntervals{i}(2));
        data = data - mean(data);
        r_full = xcorr(data, max_window_size - 1, 'biased');
        R_xx = R_xx + toeplitz(r_full(max_window_size:end));
    end
    R_xx = R_xx ./ length(noisyIntervals);

    s = eeg_data;
    for i = 1:length(noisyIntervals)
        startIdx = noisyIntervals{i}(1);
        endIdx = startIdx + max_window_size - 1;
        while true
            window = startIdx:endIdx;
            window_size = length(window);
            data = eeg_data(window);
            W = R_ss(1:window_size, 1:window_size) / R_xx(1:window_size, 1:window_size);
            s(window) = W * data;
            startIdx = endIdx;
            if endIdx == noisyIntervals{i}(2)
                break;
            else
                endIdx = min(endIdx + max_window_size - 1, noisyIntervals{i}(2));
            end
        end
    end
end
