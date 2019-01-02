function [originalDatasetPath, trainPath, testPath] = setPaths(datasetFolderName, originalDatasetName, datasetName, trainFolderName, testFolderName, isDeep2)
%% Return paths.

%% In Deep2 Datasets stored in SHARE Directory
if isDeep2 == 1
    currentPath = '/SHARE';
else
    currentPath = userpath;
    
    %% If Operating System is MAC, then remove ';' from end of current_path variable.
    if ismac == 1
        currentPath = currentPath(1:end-1);
    end
end

%% Set File Separator
f = filesep;

%% Set unpartitioned original dataset path
originalDatasetPath = strcat(currentPath, f, datasetFolderName, f, originalDatasetName);

%% Set dataset, training and test paths
datasetPath = strcat(currentPath, f, datasetFolderName, f, datasetName);
trainPath = strcat(datasetPath, f, trainFolderName);
testPath = strcat(datasetPath, f, testFolderName);

end
