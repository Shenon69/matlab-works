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
numFDFeatures = 43; % Number of FD features
numTDFeatures = 88; % Number of TD features
numTotalFeatures = numFDFeatures + numTDFeatures; % Total combined features

userVariance = zeros(numUsers, numTotalFeatures); % Preallocate for variances
userMean = zeros(numUsers, numTotalFeatures); % Preallocate for means
userCV = zeros(numUsers, numTotalFeatures); % Preallocate for CVs
userSTD = zeros(numUsers, numTotalFeatures); % Preallocate for standard deviations

% Step 6: Loop through all users and calculate inter-variances, means, CVs, and standard deviations
for userIdx = 1:numUsers
    userID = sprintf('U%02d', userIdx); % User ID in the format U01, U02, ..., U10
    
    % Check if the required fields exist for the user
    if isfield(userData, [userID '_Acc_FreqD_FDay']) && isfield(userData, [userID '_Acc_TimeD_FDay'])
        % Load the FreqD_FDay and TimeD_FDay data for the user
        FDay_FD_data = userData.([userID '_Acc_FreqD_FDay']).Acc_FD_Feat_Vec;
        FDay_TD_data = userData.([userID '_Acc_TimeD_FDay']).Acc_TD_Feat_Vec;
        
        % Combine FD and TD data along the feature axis
        FDay_combined_data = [FDay_FD_data, FDay_TD_data];
        
        % Check the size of combined data to ensure it matches expected dimensions (36 samples x 131 features)
        [numSamples, numFeatures] = size(FDay_combined_data);
        if numFeatures ~= numTotalFeatures
            error('The number of features in combined data for user %s is %d, expected %d features.', userID, numFeatures, numTotalFeatures);
        end
        
        % Calculate variances for the user's combined data
        variance_combined = var(FDay_combined_data, 0, 1); % Variance across columns (features)
        userVariance(userIdx, :) = variance_combined;
        
        % Calculate means for the user's combined data
        mean_combined = mean(FDay_combined_data, 1); % Mean across columns (features)
        userMean(userIdx, :) = mean_combined;
        
        % Calculate standard deviations for the user's combined data
        std_combined = std(FDay_combined_data, 0, 1); % Standard deviation across columns (features)
        userSTD(userIdx, :) = std_combined;
        
        % Calculate coefficients of variation (CVs) for the user's combined data
        cv_combined = std_combined ./ mean_combined;
        userCV(userIdx, :) = cv_combined;
    else
        warning('Missing data for user %s. Skipping...', userID);
    end
end

% Step 7: Create figures for the combined analysis

% Figure 1: Variance of combined FD+TD data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numTotalFeatures, userVariance(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Variance of Combined FD+TD for All Users');
xlabel('Feature Index');
ylabel('Variance');
legend('show');
grid on;

% Figure 2: Mean of combined FD+TD data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numTotalFeatures, userMean(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Mean of Combined FD+TD for All Users');
xlabel('Feature Index');
ylabel('Mean');
legend('show');
grid on;

% Figure 3: Coefficient of Variation (CV) of combined FD+TD data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numTotalFeatures, userCV(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Coefficient of Variation (CV) of Combined FD+TD for All Users');
xlabel('Feature Index');
ylabel('CV');
legend('show');
grid on;

% Figure 4: Standard Deviation of combined FD+TD data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numTotalFeatures, userSTD(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Standard Deviation of Combined FD+TD for All Users');
xlabel('Feature Index');
ylabel('Standard Deviation');
legend('show');
grid on;
