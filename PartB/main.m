clc, clearvars, close all;

train_data = load('train.mat');
test_data = load('test.mat');

%% Step 1

train_eeg = train_data.train_eeg;
N = size(train_eeg, 2);
blinks = train_data.blinks;
not_blinks = setdiff(1:N, blinks);

figure;
hold on;
scatter(blinks, ones(size(blinks)), 2, 'r', 'filled', 'o');
scatter(not_blinks, ones(size(not_blinks)), 2, 'b', 'filled', 'o');
grid on;
title('Blink Intervals');
legend({'blink', 'no blink'});

%% Single Channel Approximation

s = wiener_smoothing(train_eeg(1,:), blinks);
figure;
hold on;
plot(train_eeg(1,:));
plot(s);
grid on;
legend({'Noisy Data', 'Filtered Data'});
xlabel('t');
ylabel('V');
title('Smoothing Data');
