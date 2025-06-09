function [s_train, s_test, rmse] = wiener_smoothing_multichannel(x_train, x_test, blinks, M)

    [C, N] = size(x_train);
    [cleanIntervals, noisyIntervals, max_window_size] = find_intervals(blinks, N);

    M = min(M, max_window_size);
    D = C * M;

    R_xx = zeros(D, D);
    R_ss = zeros(D, D);

    not_blinks = setdiff(1:N, blinks);
    n_noisy = length(blinks);
    n_clean = length(not_blinks);

    noisy_mean = mean(x_train(:, blinks), 2);
    clean_mean = mean(x_train(:, not_blinks), 2);

    % Estimate clean signal covariance
    for i = 1:length(cleanIntervals)
        idx = cleanIntervals{i}(1):cleanIntervals{i}(2);
        data = x_train(:, idx) - clean_mean;
        X = build_lagged_matrix(data, M);  % [C*M x T]
        alpha = length(idx) / n_clean;
        R_ss = R_ss + alpha * (X * X') / size(X, 2);
    end

    % Estimate noisy signal covariance
    for i = 1:length(noisyIntervals)
        idx = noisyIntervals{i}(1):noisyIntervals{i}(2);
        data = x_train(:, idx) - noisy_mean;
        X = build_lagged_matrix(data, M);  % [C*M x T]
        alpha = length(idx) / n_noisy;
        R_xx = R_xx + alpha * (X * X') / size(X, 2);
    end

    % Wiener filter
    W = R_ss / R_xx;

    % Apply Wiener filter on training and testing data
    s_train = apply_wiener_smoothing_multichannel(x_train, W, M);
    s_test = apply_wiener_smoothing_multichannel(x_test, W, M);

    % Compute RMSE across channels (on clean intervals only)
    squared_errors = [];
    for i = 1:length(cleanIntervals)
        idx = cleanIntervals{i}(1):cleanIntervals{i}(2);
        err = x_train(:, idx) - s_train(:, idx);  % [C x T_clean]
        squared_errors = [squared_errors, err.^2];  % accumulate per-sample squared errors
    end

    rmse = sqrt(mean(squared_errors, 2));
end
