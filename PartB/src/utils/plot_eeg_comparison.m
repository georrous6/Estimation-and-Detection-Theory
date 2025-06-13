function plot_eeg_comparison(train_orig, train_filt, test_orig, test_filt, channel, method_name, output_dir)
    % Plots comparison between original and filtered EEG data for both train and test
    % Args:
    %   train_orig:     Original training EEG data
    %   train_filt:     Filtered training EEG data
    %   test_orig:      Original test EEG data
    %   test_filt:      Filtered test EEG data
    %   channel:        Channel number to plot
    %   method_name:    String indicating the method (e.g. 'Single-Channel-Smoothing')
    %   output_dir:     Directory to save the output plots
    %
    % Example:
    %   plot_eeg_comparison(train_eeg, s_train, test_eeg, s_test, 1, 'Single-Channel-Smoothing', outputDir)

    % Create single figure with both subplots
    figure('Position', [50 100 1440 600]);
    
    % Train data subplot
    h_train = subplot(1, 2, 1);
    hold on;
    plot(train_orig(channel,:), '-k');
    if (size(train_filt, 1) == 19)
        plot(train_filt(channel,:), '-r');
    else
        plot(train_filt, '-r');
    end
    grid on;
    legend({'Original', 'Filtered'});
    xlabel('t');
    ylabel('V');
    title(sprintf('Channel %d: %s (Train Data)', channel, method_name));
    
    % Test data subplot
    h_test = subplot(1, 2, 2);
    hold on;
    plot(test_orig(channel,:), '-k');
    if (size(test_filt, 1) == 19)
        plot(test_filt(channel,:), '-r');
    else
        plot(test_filt, '-r');
    end
    grid on;
    legend({'Original', 'Filtered'});
    xlabel('t');
    ylabel('V');
    title(sprintf('Channel %d: %s (Test Data)', channel, method_name));
    
    % Save individual subplots
    method_prefix  = lower(strrep(method_name, '-', '_'));
    
    filename_train = fullfile(output_dir, sprintf('%s_train.pdf', method_prefix));
    filename_test  = fullfile(output_dir, sprintf('%s_test.pdf', method_prefix));
    
    exportgraphics(h_train, filename_train, 'ContentType', 'vector');
    exportgraphics(h_test, filename_test, 'ContentType', 'vector');
end
