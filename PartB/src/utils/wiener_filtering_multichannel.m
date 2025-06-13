function [v_train, v_test, rmse] = wiener_filtering_multichannel(x_train, x_test, blinks, M)
    v_train = zeros(size(x_train, 1), size(x_train, 2));
    v_test  = zeros(size(x_test, 1), size(x_test, 2));

    for p = 9500:size(x_train, 2)
        x_train_ = x_train(:, 1:p);
        x_test_  = x_test(:, 1:p);
        blinks_  = blinks(blinks <= p);

        [C, N] = size(x_train_);
        [cleanIntervals, noisyIntervals, max_window_size] = find_intervals(blinks_, N);
    
        M = min(M, max_window_size);
        D = C * M;
    
        R_xx = zeros(D, D);
        R_ss = zeros(D, D);
    
        not_blinks  = setdiff(1:N, blinks_);
        n_noisy     = length(blinks_);
        n_clean     = length(not_blinks);
    
        noisy_mean = mean(x_train_(:, blinks_), 2);
        clean_mean = mean(x_train_(:, not_blinks), 2);
    
        % Estimate clean signal covariance
        for i = 1:length(cleanIntervals)
            idx     =   cleanIntervals{i}(1):cleanIntervals{i}(2);
            data    =   x_train_(:, idx) - clean_mean;
            X       =   build_lagged_matrix(data, M);  % [C*M x T]
            alpha   =   length(idx) / n_clean;
            R_ss    =   R_ss + alpha * (X * X') / size(X, 2);
        end
    
        % Estimate noisy signal covariance
        for i = 1:length(noisyIntervals)
            idx     =   noisyIntervals{i}(1):noisyIntervals{i}(2);
            data    =   x_train_(:, idx) - noisy_mean;
            X       =   build_lagged_matrix(data, M);  % [C*M x T]
            alpha   =   length(idx) / n_noisy;
            R_xx    =   R_xx + alpha * (X * X') / size(X, 2);
        end
    
        % Wiener filter
        W = R_ss / R_xx;
    
        % Apply Wiener filter on training and testing data
        s_train = apply_wiener_filtering_multichannel(x_train_, W, M);
        s_test  = apply_wiener_filtering_multichannel(x_test_, W, M);

        v_train(:, p) = s_train(:, size(s_train, 2));
        v_test(:, p)  = s_test(:, size(s_test, 2));
    end

    % Compute RMSE across channels (on clean intervals only)
    squared_errors = [];
    [cleanIntervals, ~, ~] = find_intervals(blinks_, N);
    for i = 1:length(cleanIntervals)
        idx = cleanIntervals{i}(1):cleanIntervals{i}(2);
        err = x_train(:, idx) - v_train(:, idx);  % [C x T_clean]
        squared_errors = [squared_errors, err.^2];  % accumulate per-sample squared errors
    end

    rmse = sqrt(mean(squared_errors, 2));
end
