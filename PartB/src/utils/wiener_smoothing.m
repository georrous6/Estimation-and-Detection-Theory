function [s_train, s_test, rmse] = wiener_smoothing(x_train, x_test, blinks, M)
    x_train = x_train(:);
    x_test = x_test(:);
    N = length(x_train);
    [cleanIntervals, noisyIntervals, max_window_size] = find_intervals(blinks, N);
    M = min(max_window_size, M);

    R_ss = zeros(M, M);
    R_xx = zeros(M, M);

    for i = 1:length(cleanIntervals)
        idx = cleanIntervals{i}(1):cleanIntervals{i}(2);
        data = x_train(idx);
        data = data - mean(data);
        r_full = xcorr(data, M - 1, 'biased');
        R_ss = R_ss + toeplitz(r_full(M:end));
    end
    R_ss = R_ss ./ length(cleanIntervals);

    for i = 1:length(noisyIntervals)
        idx = noisyIntervals{i}(1):noisyIntervals{i}(2);
        data = x_train(idx);
        data = data - mean(data);
        r_full = xcorr(data, M - 1, 'biased');
        R_xx = R_xx + toeplitz(r_full(M:end));
    end
    R_xx = R_xx ./ length(noisyIntervals);

    W = R_ss / R_xx;

    s_train = apply_wiener_smoothing(x_train, W, M);
    s_test = apply_wiener_smoothing(x_test, W, M);

    y = zeros(N, 1);
    y_pred = zeros(N, 1);
    for i = 1:length(cleanIntervals)
        window = cleanIntervals{i}(1):cleanIntervals{i}(2);
        y(window) = x_train(window);
        y_pred(window) = s_train(window);
    end
    rmse = sqrt(mean((y - y_pred).^2));
end
