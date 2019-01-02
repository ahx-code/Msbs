function [totalSize] = getDatasetSize(datasetPath)
%% Returns, dataset size.
%% Set File Separator
f = filesep;

%% Get Dataset Directory
datasetDirectory = dir(datasetPath); 
datasetSize = numel(datasetDirectory); 
assert(datasetSize>0, 'ERROR: getDatasetSize.m, Given Path is not Valid')

%% Initialize Total Size
totalSize = 0;

for i = 1:datasetSize
    datasetName = datasetDirectory(i).name; 
    isWanted = isWantedFile(datasetName);
    
    if isWanted == 1
        datasetFolder = strcat(datasetPath, f, datasetName);
        labelDirectory = dir(datasetFolder); 
        labelSize = numel(labelDirectory);
        
        for j = 1:labelSize
            labelName = labelDirectory(j).name; 
            isWanted = isWantedFile(labelName);
            
            if isWanted == 1
                totalSize = totalSize + 1;
            end
        end
    end
end
end
