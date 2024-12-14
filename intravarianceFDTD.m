clearvars

% Step 1: Define the path to the data folder
dataFolder = fullfile(pwd, 'CW-Data');

% Step 2: Get a list of all .mat files in the folder
matFiles = dir(fullfile(dataFolder, '*.mat'));

% Step 3: Initialize a structure to store the loaded data
userData = struct();

% Step 4: Load all .mat files into a structured format
for i = 1:length(matFiles)
    % Full path of the current file
    filePath = fullfile(dataFolder, matFiles(i).name);
    
    % Load the current .mat file
    data = load(filePath);
    
    % Use the file name (without the .mat extension) as the field name
    fieldName = erase(matFiles(i).name, '.mat');  % Remove '.mat' from the file name
    userData.(fieldName) = data;  % Store data in the structure with the field name
end

% Step 5: Identify users and initialize variables
numUsers = 10; % Number of users
featureTypes = {'FreqD_FDay', 'TimeD_MDay'}; % Feature sets to compare
results = struct();

% Step 6: Loop through all users and calculate intra-variances, CVs, and standard deviations
for userIdx = 1:numUsers
    userID = sprintf('U%02d', userIdx); % User ID in the format U01, U02, ..., U10
    
    % Check if the required fields exist for the user
    if isfield(userData, [userID '_Acc_FreqD_FDay']) && isfield(userData, [userID '_Acc_FreqD_MDay']) && isfield(userData, [userID '_Acc_TimeD_MDay'])
        % Load the data for FDay and MDay
        FDay_data = userData.([userID '_Acc_FreqD_FDay']).Acc_FD_Feat_Vec; % FreqD_FDay
        MDay_data_FreqD = userData.([userID '_Acc_FreqD_MDay']).Acc_FD_Feat_Vec; % FreqD_MDay
        MDay_data_TimeD = userData.([userID '_Acc_TimeD_MDay']).Acc_TD_Feat_Vec; % TimeD_MDay

        % Combine FreqD_FDay and TimeD_MDay (resulting in 131 features)
        combined_FreqD_TimeD = [FDay_data, MDay_data_TimeD];
        
        % Combine FreqD_MDay and TimeD_MDay
        combined_MDay_TimeD = [MDay_data_FreqD, MDay_data_TimeD];
        
        % Calculate variances for the combined data
        variance_combined_FreqD_TimeD = var(combined_FreqD_TimeD, 0, 1); % Variance across columns (features)
        variance_combined_MDay_TimeD = var(combined_MDay_TimeD, 0, 1);

        % Calculate means
        mean_combined_FreqD_TimeD = mean(combined_FreqD_TimeD, 1);
        mean_combined_MDay_TimeD = mean(combined_MDay_TimeD, 1);

        % Calculate standard deviations
        std_combined_FreqD_TimeD = sqrt(variance_combined_FreqD_TimeD);
        std_combined_MDay_TimeD = sqrt(variance_combined_MDay_TimeD);

        % Calculate coefficients of variation (CVs)
        cv_combined_FreqD_TimeD = std_combined_FreqD_TimeD ./ mean_combined_FreqD_TimeD;
        cv_combined_MDay_TimeD = std_combined_MDay_TimeD ./ mean_combined_MDay_TimeD;

        % Store results for the user
        results.(userID).variance_combined_FreqD_TimeD = variance_combined_FreqD_TimeD;
        results.(userID).variance_combined_MDay_TimeD = variance_combined_MDay_TimeD;
        results.(userID).std_combined_FreqD_TimeD = std_combined_FreqD_TimeD;
        results.(userID).std_combined_MDay_TimeD = std_combined_MDay_TimeD;
        results.(userID).cv_combined_FreqD_TimeD = cv_combined_FreqD_TimeD;
        results.(userID).cv_combined_MDay_TimeD = cv_combined_MDay_TimeD;

        % Feature indices (131 features in total)
        numFeatures = length(variance_combined_FreqD_TimeD);
        featureIndices = 1:numFeatures;

        % Create a dedicated figure for this user
        figure;
        
        % Subplot 1: Variance
        subplot(3, 1, 1); % First subplot for variance
        hold on;
        plot(featureIndices, variance_combined_FreqD_TimeD, '-o', 'DisplayName', 'Combined FreqD_FDay and TimeD_MDay Variance');
        plot(featureIndices, variance_combined_MDay_TimeD, '-x', 'DisplayName', 'Combined FreqD_MDay and TimeD_MDay Variance');
        hold off;
        title(sprintf('User %02d: Combined Feature Variances (FreqD and TimeD)', userIdx));
        xlabel('Feature Index');
        ylabel('Variance');
        legend('show');
        grid on;

        % Subplot 2: Coefficient of Variation
        subplot(3, 1, 2); % Second subplot for CV
        hold on;
        plot(featureIndices, cv_combined_FreqD_TimeD, '-o', 'DisplayName', 'Combined FreqD_FDay and TimeD_MDay CV');
        plot(featureIndices, cv_combined_MDay_TimeD, '-x', 'DisplayName', 'Combined FreqD_MDay and TimeD_MDay CV');
        hold off;
        title(sprintf('User %02d: Combined Coefficient of Variation (CV, FreqD and TimeD)', userIdx));
        xlabel('Feature Index');
        ylabel('CV');
        legend('show');
        grid on;

        % Subplot 3: Standard Deviation
        subplot(3, 1, 3); % Third subplot for standard deviation
        hold on;
        plot(featureIndices, std_combined_FreqD_TimeD, '-o', 'DisplayName', 'Combined FreqD_FDay and TimeD_MDay Std Dev');
        plot(featureIndices, std_combined_MDay_TimeD, '-x', 'DisplayName', 'Combined FreqD_MDay and TimeD_MDay Std Dev');
        hold off;
        title(sprintf('User %02d: Combined Standard Deviations (FreqD and TimeD)', userIdx));
        xlabel('Feature Index');
        ylabel('Standard Deviation');
        legend('show');
        grid on;
    else
        warning('Missing data for user %s. Skipping...', userID);
    end
end
