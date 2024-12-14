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
numFeatures = 88;  % Correct number of features in TimeD_FDay
numSamples = 36;   % Number of samples

userVariance = zeros(numUsers, numFeatures);  % Preallocate for variances (88 features)
userMean = zeros(numUsers, numFeatures);  % Preallocate for means (88 features)
userCV = zeros(numUsers, numFeatures);  % Preallocate for CVs (88 features)
userSTD = zeros(numUsers, numFeatures);  % Preallocate for standard deviations (88 features)

% Step 6: Loop through all users and calculate intra-variances, means, CVs, and STDs
for userIdx = 1:numUsers
    userID = sprintf('U%02d', userIdx); % User ID in the format U01, U02, ..., U10
    
    % Check if the required field exists for the user
    if isfield(userData, [userID '_Acc_TimeD_FDay'])
        % Load the TimeD_FDay data for the user
        TimeD_FDay_data = userData.([userID '_Acc_TimeD_FDay']).Acc_TD_Feat_Vec; % TimeD_FDay data
        
        % Check the size of TimeD_FDay_data to ensure it matches expected dimensions (36 samples x 88 features)
        [numSamples, numFeatures] = size(TimeD_FDay_data);
        if numFeatures ~= 88
            error('The number of features in TimeD_FDay_data for user %s is %d, expected 88 features.', userID, numFeatures);
        end
        
        % Calculate variances for the user's TimeD_FDay data
        variance_TimeD_FDay = var(TimeD_FDay_data, 0, 1); % Variance across columns (features)
        userVariance(userIdx, :) = variance_TimeD_FDay;
        
        % Calculate means for the user's TimeD_FDay data
        mean_TimeD_FDay = mean(TimeD_FDay_data, 1); % Mean across columns (features)
        userMean(userIdx, :) = mean_TimeD_FDay;
        
        % Calculate standard deviations for the user's TimeD_FDay data
        std_TimeD_FDay = std(TimeD_FDay_data, 0, 1); % Standard deviation across columns (features)
        userSTD(userIdx, :) = std_TimeD_FDay;
        
        % Calculate coefficients of variation (CVs) for the user's TimeD_FDay data
        cv_TimeD_FDay = std_TimeD_FDay ./ mean_TimeD_FDay;
        userCV(userIdx, :) = cv_TimeD_FDay;
    else
        warning('Missing data for user %s. Skipping...', userID);
    end
end

% Step 7: Create figures for the analysis

% Figure 1: Variance of TimeD_FDay data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numFeatures, userVariance(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Variance of TimeD_FDay for All Users');
xlabel('Feature Index');
ylabel('Variance');
legend('show');
grid on;

% Figure 2: Mean of TimeD_FDay data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numFeatures, userMean(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Mean of TimeD_FDay for All Users');
xlabel('Feature Index');
ylabel('Mean');
legend('show');
grid on;

% Figure 3: Coefficient of Variation (CV) of TimeD_FDay data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numFeatures, userCV(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Coefficient of Variation (CV) of TimeD_FDay for All Users');
xlabel('Feature Index');
ylabel('CV');
legend('show');
grid on;

% Figure 4: Standard Deviation of TimeD_FDay data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numFeatures, userSTD(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Standard Deviation of TimeD_FDay for All Users');
xlabel('Feature Index');
ylabel('Standard Deviation');
legend('show');
grid on;
