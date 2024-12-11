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
numFeatures = 43;  % Number of features in FreqD_FDay
userVariance = zeros(numUsers, numFeatures);  % Preallocate for variances (43 features)
userMean = zeros(numUsers, numFeatures);  % Preallocate for means (43 features)
userCV = zeros(numUsers, numFeatures);  % Preallocate for CVs (43 features)

% Step 6: Loop through all users and calculate intra-variances, means, and CVs
for userIdx = 1:numUsers
    userID = sprintf('U%02d', userIdx); % User ID in the format U01, U02, ..., U10
    
    % Check if the required field exists for the user
    if isfield(userData, [userID '_Acc_FreqD_FDay'])
        % Load the FreqD_FDay data for the user
        FDay_data = userData.([userID '_Acc_FreqD_FDay']).Acc_FD_Feat_Vec; % FreqD_FDay data
        
        % Check the size of FDay_data to ensure it matches expected dimensions (36 samples x 43 features)
        [numSamples, numFeatures] = size(FDay_data);
        if numFeatures ~= 43
            error('The number of features in FDay_data for user %s is %d, expected 43 features.', userID, numFeatures);
        end
        
        % Calculate variances for the user's FreqD_FDay data
        variance_FDay = var(FDay_data, 0, 1); % Variance across columns (features)
        userVariance(userIdx, :) = variance_FDay;
        
        % Calculate means for the user's FreqD_FDay data
        mean_FDay = mean(FDay_data, 1); % Mean across columns (features)
        userMean(userIdx, :) = mean_FDay;
        
        % Calculate standard deviations for the user's FreqD_FDay data
        std_FDay = std(FDay_data, 0, 1); % Standard deviation across columns (features)
        
        % Calculate coefficients of variation (CVs) for the user's FreqD_FDay data
        cv_FDay = std_FDay ./ mean_FDay;
        userCV(userIdx, :) = cv_FDay;
    else
        warning('Missing data for user %s. Skipping...', userID);
    end
end

% Step 7: Create figures for the analysis

% Figure 1: Variance of FreqD_FDay data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numFeatures, userVariance(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Variance of FreqD_FDay for All Users');
xlabel('Feature Index');
ylabel('Variance');
legend('show');
grid on;

% Figure 2: Mean of FreqD_FDay data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numFeatures, userMean(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Mean of FreqD_FDay for All Users');
xlabel('Feature Index');
ylabel('Mean');
legend('show');
grid on;

% Figure 3: Coefficient of Variation (CV) of FreqD_FDay data for all 10 users
figure;
hold on;
for userIdx = 1:numUsers
    plot(1:numFeatures, userCV(userIdx, :), 'DisplayName', sprintf('User %02d', userIdx));
end
hold off;
title('Coefficient of Variation (CV) of FreqD_FDay for All Users');
xlabel('Feature Index');
ylabel('CV');
legend('show');
grid on;
