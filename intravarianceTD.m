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
featureTypes = {'TimeD_FDay', 'TimeD_MDay'}; % Feature sets to compare
results = struct();

% Step 6: Loop through all users and calculate intra-variances and CVs
for userIdx = 1:numUsers
    userID = sprintf('U%02d', userIdx); % User ID in the format U01, U02, ..., U10
    
    % Check if the required fields exist for the user
    if isfield(userData, [userID '_Acc_TimeD_FDay']) && isfield(userData, [userID '_Acc_TimeD_MDay'])
        % Load the data for FDay and MDay
        FDay_data = userData.([userID '_Acc_TimeD_FDay']).Acc_TD_Feat_Vec;
        MDay_data = userData.([userID '_Acc_TimeD_MDay']).Acc_TD_Feat_Vec;
        
        % Calculate variances for FDay and MDay
        variance_FDay = var(FDay_data, 0, 1); % Variance across rows for each feature
        variance_MDay = var(MDay_data, 0, 1);
        
        % Calculate means
        mean_FDay = mean(FDay_data, 1);
        mean_MDay = mean(MDay_data, 1);
        
        % Calculate standard deviations
        std_FDay = sqrt(variance_FDay);
        std_MDay = sqrt(variance_MDay);
        
        % Calculate coefficients of variation (CVs)
        cv_FDay = std_FDay ./ mean_FDay;
        cv_MDay = std_MDay ./ mean_MDay;
        
        % Store results for the user
        results.(userID).variance_FDay = variance_FDay;
        results.(userID).variance_MDay = variance_MDay;
        results.(userID).std_FDay = std_FDay;
        results.(userID).std_MDay = std_MDay;
        results.(userID).cv_FDay = cv_FDay;
        results.(userID).cv_MDay = cv_MDay;

        % Feature indices
        numFeatures = length(variance_FDay);
        featureIndices = 1:numFeatures;

        % Create a dedicated figure for this user
        figure;
        
        % Subplot 1: Variance
        subplot(3, 1, 1); % First subplot for variance
        hold on;
        plot(featureIndices, variance_FDay, '-o', 'DisplayName', 'FDay Variance');
        plot(featureIndices, variance_MDay, '-x', 'DisplayName', 'MDay Variance');
        hold off;
        title(sprintf('User %02d: Feature Variances (TimeD)', userIdx));
        xlabel('Feature Index');
        ylabel('Variance');
        legend('show');
        grid on;

        % Subplot 2: Coefficient of Variation
        subplot(3, 1, 2); % Second subplot for CV
        hold on;
        plot(featureIndices, cv_FDay, '-o', 'DisplayName', 'FDay CV');
        plot(featureIndices, cv_MDay, '-x', 'DisplayName', 'MDay CV');
        hold off;
        title(sprintf('User %02d: Coefficient of Variation (CV, TimeD)', userIdx));
        xlabel('Feature Index');
        ylabel('CV');
        legend('show');
        grid on;

        % Subplot 3: Standard Deviation
        subplot(3, 1, 3); % Third subplot for standard deviation
        hold on;
        plot(featureIndices, std_FDay, '-o', 'DisplayName', 'FDay STD');
        plot(featureIndices, std_MDay, '-x', 'DisplayName', 'MDay STD');
        hold off;
        title(sprintf('User %02d: Standard Deviations (TimeD)', userIdx));
        xlabel('Feature Index');
        ylabel('Standard Deviation');
        legend('show');
        grid on;
    else
        warning('Missing data for user %s. Skipping...', userID);
    end
end
