function [scoreTotal] = getNeighborhoodTemplate(originalDatasetPath, R1, R2, downsampleRatio, imageHeight, imageWidth, datasetSize)
%% GETNEIGHBORHOODTEMPLATE Returns the neighborhood score total.

if exist('vectorized_set.mat', 'file')
    fprintf('\nLoading vectorized_set.mat...\n');
    load('vectorized_set.mat', 'imgset');
else
    %% Initialize File Separator
    f = filesep;
    
    %% Get Dataset Directory and Size
    datasetDirectory = dir(originalDatasetPath);
    datasetDirectorySize = numel(datasetDirectory);
    
    %% Count the Number of Different Image Size
    differentSizedImagesCounter = 0;
    
    %% Check Whether the Directory Given Correctly
    assert(datasetDirectorySize>0, 'ERROR: getNeighborhoodTemplate.m')
    
    %% Initialize Image Counter
    imageCounter = 0;
    
    %% Initialize Image Set
    imgset = ones(datasetSize, (imageHeight*imageWidth)) * (-1);
    
    %% For each Label in Dataset
    for i = 1:datasetDirectorySize
        datasetName = datasetDirectory(i).name;
        isWanted = isWantedFile(datasetName);
        
        if isWanted == 1
            datasetFolder = strcat(originalDatasetPath, f, datasetName);
            labelDirectory = dir(datasetFolder);
            labelSize = numel(labelDirectory);
            assert(labelSize>0, 'ERROR: getNeighborhoodTemplate.m')
            
            %% For each Image in Label
            for j = 1:labelSize
                %% Get Label Name
                labelName = labelDirectory(j).name;
                isWanted = isWantedFile(labelName);
                if isWanted == 1
                    %% Get Image Name
                    imagePath = strcat(datasetFolder, f, labelName);
                    
                    %% Read Image
                    I = imread(imagePath);
                    
                    %% If Image is RGB, convert to grey-scale
                    if size(I, 3) == 3
                        I = convert2grey(I);
                    end
                    
                    %% If Downsample ratio defined, downsample Image
                    if downsampleRatio ~= 0
                        I = downsampleImage(I, downsampleRatio);
                    end
                    
                    %% If Current Image is not the same size with image height and width
                    if size(I,1) ~= imageHeight || size(I,2) ~= imageWidth
                        I = imresize(I, [imageHeight, imageWidth]);
                        differentSizedImagesCounter = differentSizedImagesCounter + 1;
                    end
                    
                    %% Normalize Image Pixels
                    double_I = double(I);
                    for k=1:size(double_I, 3)
                        double_I(:,:,k) = double_I(:,:,k)./255.0;
                    end
                    
                    %% Convert Image into Vector Form, Assuming each image in dataset have same size.
                    vectorizedImage = reshape(double_I, [1, imageHeight * imageWidth]);
                    
                    %% Increase Count by 1
                    imageCounter = imageCounter + 1;
                    
                    %% Add to image set
                    imgset(imageCounter, :) = vectorizedImage;
                end
            end
        end
    end
    save('vectorized_set.mat','imgset');
    fprintf('\nThere are %d different size images\n', differentSizedImagesCounter);
    fprintf('\nAll Images Stored into Vector\n');
end

%% Initialize Score Total
scoreTotal = zeros(2*R2+1, 2*R2+1);

%% Initialize Minor Patch Length
minorPatchLength = (2*R2+1);

for i = 1:size(imgset, 1)
    %% Read Image
    I = reshape(imgset(i, :), [imageHeight, imageWidth]);
    
    %% Get Image Size
    [ysize, xsize] = size(I);
    
    %% Get Major Patch Center Pixel.
    majorPatchCenterPixelX = R1+1;
    majorPatchCenterPixelY = R1+1;
    majorPatchCP = [majorPatchCenterPixelY, majorPatchCenterPixelX];
    
    %% Calculate Total Movement Inside Image
    totalMovementY = ysize-(2*R1+1)+1;
    totalMovementX = xsize-(2*R1+1)+1;
    
    %% Check Whether it is possible to move inside Image
    if totalMovementY <= 0 || totalMovementX <= 0
        error('Pmaj size is too large to move inside Image.');
    end
    
    for k = 1:totalMovementY
        for l = 1:totalMovementX
            %% Get Major Patch
            majorPatch = I(majorPatchCP(1)-R1:majorPatchCP(1)+R1, majorPatchCP(2)-R1:majorPatchCP(2)+R1);
            
            %% Get Major Patch Coordinates
            s = size(majorPatch,1);
            majorCoordY = repmat((majorPatchCP(1)-R1:majorPatchCP(1)+R1), [s,1])';
            majorCoordX = repmat((majorPatchCP(2)-R1:majorPatchCP(2)+R1), [s,1]);
            
            %% Get Pivot Patch
            pivotPatch = I(majorPatchCP(1)-R2:majorPatchCP(1)+R2, majorPatchCP(2)-R2:majorPatchCP(2)+R2);
            
            %% Move Inside Major Patch
            for m = 1:size(majorPatch, 1)-minorPatchLength+1
                for n = 1:size(majorPatch, 2)-minorPatchLength+1
                    %% Get Corresponding Spatial Coordinates
                    ycoord = majorCoordY(m,n):majorCoordY(m,n)+2*R2;
                    xcoord = majorCoordX(m,n):majorCoordX(m,n)+2*R2;
                    
                    %% Get Minor Patch
                    minorPatch = I(ycoord, xcoord);
                    
                    %% Get Center Pixel Values
                    minorPatchCenterPixel = minorPatch(1+R2, 1+R2);
                    pivotPatchCenterPixel = pivotPatch(1+R2, 1+R2);
                    
                    %% Based on Minor Patch Center Pixel to Pivot Patch Center Pixel Relationship
                    if minorPatchCenterPixel >= pivotPatchCenterPixel
                        for s = 1:size(minorPatch, 1)
                            for t = 1:size(minorPatch, 2)
                                if minorPatch(s, t) >= pivotPatch(s, t)
                                    scoreTotal(s, t) = scoreTotal(s, t) + 1;
                                elseif minorPatch(s, t) < pivotPatch(s, t)
                                    scoreTotal(s, t) = scoreTotal(s, t) - 1;
                                else
                                    error('ERROR: @ getNeighborhoodTemplate.m Score Calculation minorPatchCenterPixel >= pivotPatchCenterPixel');
                                end
                            end
                        end
                    elseif minorPatchCenterPixel < pivotPatchCenterPixel
                        for s = 1:size(minorPatch, 1)
                            for t = 1:size(minorPatch, 2)
                                if minorPatch(s, t) < pivotPatch(s, t)
                                    scoreTotal(s, t) = scoreTotal(s, t) + 1;
                                elseif minorPatch(s, t) >= pivotPatch(s, t)
                                    scoreTotal(s, t) = scoreTotal(s, t) - 1;
                                else
                                    error('ERROR: @ getNeighborhoodTemplate.m Score Calculation minorPatchCenterPixel < pivotPatchCenterPixel');
                                end
                            end
                        end
                    end
                end
            end
            
            if l == totalMovementX
                majorPatchCenterPixelX = R1+1;
                majorPatchCenterPixelY = majorPatchCenterPixelY+1;
            else
                majorPatchCenterPixelX = majorPatchCenterPixelX+1;
            end
            %% Get Major Patch Center Pixel
            majorPatchCP = [majorPatchCenterPixelY, majorPatchCenterPixelX];
        end
    end
    %% For Each 1000 image Processed, Print to Screen
    if mod(i,1000) == 0
        fprintf('%d label scores calculated. \n', i);
    end
end
end
