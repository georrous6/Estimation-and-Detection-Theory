clc, clearvars, close all;
addpath("utils");

%% Fetch data

train_data = load('train.mat');
test_data = load('test.mat');
plot_channel = 1;

train_eeg = train_data.train_eeg;
test_eeg = test_data.test_eeg;
[n_channels, N] = size(train_eeg);
blinks = train_data.blinks;
not_blinks = setdiff(1:N, blinks);

%% Plot noisy and clean intervals from training set

figure;
hold on;
scatter(blinks, ones(size(blinks)), 2, 'r', 'filled', 'o');
scatter(not_blinks, ones(size(not_blinks)), 2, 'b', 'filled', 'o');
grid on;
title('Blink Intervals');
legend({'blink', 'no blink'});

%% Plot autocorrelation

% nlags = 50;
% figure;
% autocorr(train_eeg(plot_channel, blinks), 'NumLags', nlags);
% 
% figure;
% parcorr(train_eeg(plot_channel, blinks), 'NumLags', nlags);

%% Single Channel Smoothing

M = 2000;
rmse = zeros(n_channels, 1);
for i = 1:n_channels
    [s_train, s_test, rmse(i)] = wiener_smoothing(train_eeg(i,:), test_eeg(i,:), blinks, M);
    if i == plot_channel
        figure;
        hold on;
        plot(train_eeg(i,:), '-k');
        plot(s_train, '-r');
        grid on;
        legend({'Original', 'Filtered'});
        xlabel('t');
        ylabel('V');
        title(sprintf('Channel %d: Single-Channel Smoothing (Train Data)', i));
        hold off;

        figure;
        hold on;
        plot(test_eeg(i,:), '-k');
        plot(s_test, '-r');
        grid on;
        legend({'Original', 'Filtered'});
        xlabel('t');
        ylabel('V');
        title(sprintf('Channel %d: Single-Channel Smoothing (Test Data)', i));
        hold off;
    end
end

fprintf('Single-Channel RMSE (avg): %f\n', mean(rmse));


%% Multichannel Smoothing
M = 2;
[s_train, s_test, rmse] = wiener_smoothing_multichannel(train_eeg, test_eeg, blinks, M);
fprintf('Multi-Channel RMSE (avg): %f\n', mean(rmse));

figure;
hold on;
plot(train_eeg(plot_channel,:), '-k');
plot(s_train(plot_channel,:), '-r');
grid on;
legend({'Original', 'Filtered'});
xlabel('t');
ylabel('V');
title(sprintf('Channel %d: Multi-Channel Smoothing (Train Data)', plot_channel));
hold off;

figure;
hold on;
plot(test_eeg(plot_channel,:), '-k');
plot(s_test(plot_channel,:), '-r');
grid on;
legend({'Original', 'Filtered'});
xlabel('t');
ylabel('V');
title(sprintf('Channel %d: Multi-Channel Smoothing (Test Data)', plot_channel));
hold off;
