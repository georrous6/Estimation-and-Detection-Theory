function X = build_lagged_matrix(data, M)
    % data: [C x T]
    [C, T] = size(data);
    T_windows = T - M + 1;
    X = zeros(C * M, T_windows);

    for t = 1:T_windows
        block = data(:, t:t+M-1);  % [C x M]
        X(:, t) = block(:);        % [C*M x 1]
    end
end
