function [s_train, s_test, rmse] = wiener_smoothing(x_train, x_test, blinks, M)

    x_train = x_train(:);
    x_test = x_test(:);
    N = length(x_train);
    [cleanIntervals, noisyIntervals, max_window_size] = find_intervals(blinks, N);
    M = min(max_window_size, M);

    R_ss = zeros(M, M);
    R_xx = zeros(M, M);

    not_blinks = setdiff(1:N, blinks);
    n_noisy = length(blinks);
    n_clean = length(not_blinks);

    noisy_mean = mean(x_train(blinks));
    clean_mean = mean(x_train(not_blinks));

    for i = 1:length(cleanIntervals)
        idx = cleanIntervals{i}(1):cleanIntervals{i}(2);
        data = x_train(idx) - clean_mean;
        r_full = xcorr(data, M - 1, 'unbiased');
        alpha = length(idx) / n_clean;
        R_ss = R_ss + alpha * toeplitz(r_full(M:end));
    end

    for i = 1:length(noisyIntervals)
        idx = noisyIntervals{i}(1):noisyIntervals{i}(2);
        data = x_train(idx) - noisy_mean;
        r_full = xcorr(data, M - 1, 'unbiased');
        alpha = length(idx) / n_noisy;
        R_xx = R_xx + alpha * toeplitz(r_full(M:end));
    end

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
