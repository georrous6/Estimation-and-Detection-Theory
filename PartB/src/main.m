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
rmse = zeros(n_channels, 1);
for i = 1:n_channels
    [s_train, s_test, rmse(i)] = wiener_smoothing(train_eeg(i,:), test_eeg(i,:), blinks, M);
    if i == plot_channel
        plot_eeg_comparison(train_eeg, s_train, test_eeg, s_test, i, 'Single-Channel-Smoothing', outputDir);
    end
end

fprintf('Single-Channel-Smoothing RMSE (avg): %f\n', mean(rmse));


%% Multichannel Smoothing
M = 2;
[s_train, s_test, rmse] = wiener_smoothing_multichannel(train_eeg, test_eeg, blinks, M);
fprintf('Multi-Channel-Smoothing RMSE (avg): %f\n', mean(rmse));

plot_eeg_comparison(train_eeg, s_train, test_eeg, s_test, plot_channel, 'Multi-Channel-Smoothing', outputDir);
