%% DET Assignment
% Authors: Aristeidis Daskalopoulos, Georgios Rousomanis

clc, clearvars, close all;
addpath("utils");
outputDir = fullfile('..', 'plot');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end


%% Fetch data

plot_channel    = 1;  % Choose a channel to plot

train_data      = load('train.mat');
test_data       = load('test.mat');

train_eeg           =   train_data.train_eeg;
test_eeg            =   test_data.test_eeg;
blinks              =   train_data.blinks;
[n_channels, N]     =   size(train_eeg);
not_blinks          =   setdiff(1:N, blinks);


%% Plot noisy and clean intervals from training set

figure;
hold on;
scatter(blinks, ones(size(blinks)), 2, 'r', 'filled', 'o');
scatter(not_blinks, ones(size(not_blinks)), 2, 'b', 'filled', 'o');
grid on;
title('Blink Intervals (Train Data)');
legend({'blink', 'no blink'});

filename = fullfile(outputDir, 'clean_and_noisy_intervals.pdf');
exportgraphics(gcf, filename, 'ContentType', 'vector');


%% Single Channel Smoothing

M = 1000;
rmse_single_channel_smooth = zeros(n_channels, 1);
for i = 1:n_channels
    [s_train, s_test, rmse_single_channel_smooth(i)] = wiener_smoothing(train_eeg(i,:), test_eeg(i,:), blinks, M);
    if i == plot_channel
        plot_eeg_comparison(train_eeg, s_train, test_eeg, s_test, i, 'Single-Channel-Smoothing', outputDir);
    end
end

fprintf('Single-Channel-Smoothing RMSE (avg): %f\n', mean(rmse_single_channel_smooth));


%% Multichannel Smoothing
M = 2;
[s_train, s_test, rmse_multi_channel_smooth] = wiener_smoothing_multichannel(train_eeg, test_eeg, blinks, M);
fprintf('Multi-Channel-Smoothing RMSE (avg): %f\n', mean(rmse_multi_channel_smooth));

plot_eeg_comparison(train_eeg, s_train, test_eeg, s_test, plot_channel, 'Multi-Channel-Smoothing', outputDir);


%% Plot Single vs Multichannel RMSE
figure;
plot(1:n_channels, [rmse_single_channel_smooth, rmse_multi_channel_smooth], 'LineWidth', 1.5);
legend({'Single-channel', 'Multi-channel'});
xlabel('Channel index');
ylabel('RMSE [V]');
title('RMSE for Single vs Multi-Channel Smoothing');
grid on;

filename = fullfile(outputDir, 'single_vs_multi_channel_RMSE.pdf');
exportgraphics(gcf, filename, 'ContentType', 'vector');


%% Multichannel Filtering
M = 2;
[s_train, s_test, rmse_multi_channel_filter] = wiener_filtering_multichannel(train_eeg, test_eeg, blinks, M);
fprintf('Multi-Channel-Filtering RMSE (avg): %f\n', mean(rmse_multi_channel_filter));

plot_eeg_comparison(train_eeg, s_train, test_eeg, s_test, plot_channel, 'Multi-Channel-Filtering', outputDir);

