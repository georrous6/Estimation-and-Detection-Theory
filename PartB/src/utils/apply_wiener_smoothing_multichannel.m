function s = apply_wiener_smoothing_multichannel(x, W, M)

    [C, N] = size(x);
    D = C * M;
    s = zeros(C, N);
    for t = M:N
        idx = t - M + 1:t;
        x_block = x(:, idx);        % [C x M]
        x_vec = reshape(x_block, [D, 1]);  % [C*M x 1], time-major vectorization
        s_vec = W * x_vec;

        % Extract the clean estimate for the LAST time step in the window
        s_block = reshape(s_vec, [C, M]);  % [C x M]
        s(:, t) = s_block(:, end);         % use last column as output for time t
    end
end