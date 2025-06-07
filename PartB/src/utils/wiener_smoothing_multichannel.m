function [s_train, s_test, rmse] = wiener_smoothing_multichannel(x_train, x_test, blinks, M)

    [C, N] = size(x_train);
    [cleanIntervals, noisyIntervals, max_window_size] = find_intervals(blinks, N);

    M = min(M, max_window_size);
    D = C * M;

    R_xx = zeros(D, D);
    R_ss = zeros(D, D);

    % Estimate clean signal covariance
    for i = 1:length(cleanIntervals)
        idx = cleanIntervals{i}(1):cleanIntervals{i}(2);
        data = x_train(:, idx);
        data = data - mean(data, 2);
        X = build_lagged_matrix(data, M);  % [C*M x T]
        R_ss = R_ss + (X * X') / size(X, 2);
    end
    R_ss = R_ss / length(cleanIntervals);

    % Estimate noisy signal covariance
    for i = 1:length(noisyIntervals)
        idx = noisyIntervals{i}(1):noisyIntervals{i}(2);
        data = x_train(:, idx);
        data = data - mean(data, 2);
        X = build_lagged_matrix(data, M);  % [C*M x T]
        R_xx = R_xx + (X * X') / size(X, 2);
    end
    R_xx = R_xx / length(noisyIntervals);

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
