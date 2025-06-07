function s = apply_wiener_smoothing(x, W, M)

    N = length(x);
    startIdx = 1;
    endIdx = min(startIdx + M - 1, N);
    s = x;
    while true
        window = startIdx:endIdx;
        window_size = length(window);
        data = x(window);
        s(window) = W(1:window_size, 1:window_size) * data;
        if endIdx == N
            break;
        else
            startIdx = endIdx;
            endIdx = min(endIdx + M - 1, N);
        end     
    end
end