function s = apply_wiener_filtering_multichannel(x, W, M)

    [C, N]      =   size(x);
    s           =   zeros(C, N);
    startIdx    =   1;
    endIdx      =   min(startIdx + M - 1, N);
    while true
        window      = startIdx:endIdx;
        window_size = length(window);
        x_block     = x(:, window);
        D           = C * window_size;
        x_vec       = reshape(x_block, [D, 1]);  % [D x 1], time-major vectorization
        s_vec       = W(1:D, 1:D) * x_vec;

        s_block         = reshape(s_vec, [C, window_size]);
        s(:, window)    = s_block;
        if endIdx == N
            break;
        else
            startIdx    = endIdx + 1;
            endIdx      = min(endIdx + M, N);
        end
    end
end
