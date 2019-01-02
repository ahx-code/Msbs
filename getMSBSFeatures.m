function [msbsFeatures, msbsLabels] = getMSBSFeatures(datasetPath, bin, R1, R2, spatialCoordinates, isUniform, downsampleRatio, CELL_SIZE)
%% Returns msbs features

%% Set File Separator
f = filesep;

%% Initialize msbs features
msbsFeatures = [];
msbsLabels = [];

%% Get Dataset Length
datasetDirectory = dir(datasetPath);
datasetLength = numel(datasetDirectory);

%% Initialize Neighbor Size
neighborSize = size(spatialCoordinates, 1);

%% Calculate The Distance of Center Pixel to Neighbor Pixel
if exist('distanceToNeighborCoordinates.mat', 'file')
    fprintf('\nLoading distanceToNeighborCoordinates.mat...\n');
    load('distanceToNeighborCoordinates.mat', 'distanceToNeighborCoordinates');
else
    distanceToNeighborCoordinates(:,1) = ones(1, neighborSize)*(-1);
    distanceToNeighborCoordinates(:,2) = ones(1, neighborSize)*(-1);
    
    ycenterpixel = R2+1;
    xcenterpixel = R2+1;
    
    for i = 1:neighborSize
        ycurrent = spatialCoordinates(i, 1);
        xcurrent = spatialCoordinates(i, 2);
        ynew = ycurrent - ycenterpixel;
        xnew = xcurrent - xcenterpixel;
        distanceToNeighborCoordinates(i, 1) = ynew;
        distanceToNeighborCoordinates(i, 2) = xnew;
    end
    
    save('distanceToNeighborCoordinates.mat','distanceToNeighborCoordinates');
    fprintf('\ndistanceToNeighborCoordinates Stored into Vector\n');
end

%% If Cell Size is defined, initialize currentFeatures variable as Dynamic Vector
if isempty(CELL_SIZE) == 0
    currentFeatures = [];
end

%% Extract MSBS Features from Dataset
for i = 1:datasetLength
    labelName = datasetDirectory(i).name;
    isWanted = isWantedFile(labelName);
    
    if isWanted == 1
        labelFolder = strcat(datasetPath, f, labelName);
        labelDirectory = dir(labelFolder);
        labelSize = numel(labelDirectory);
        assert(labelSize > 0, 'Label Size must be Greater Than 0.');
        
        for j = 1:labelSize
            imageName = labelDirectory(j).name;
            isWanted = isWantedFile(imageName);
            
            if isWanted == 1
                %% Get Image Path
                imagePath = strcat(labelFolder, f, imageName);
                
                %% Read Image
                I = imread(imagePath);
                
                %% If Image RGB conver tot GreyScale
                if size(I,3) == 3
                    I = convert2grey(I);
                end
                
                %% If Downsample Ratio defined, apply
                if downsampleRatio ~= 0
                    I = downsampleImage(I, downsampleRatio);
                end
                
                %% If Cell Size Defined Apply
                if isempty(CELL_SIZE) == 0
                    %% Divide image with Defined Cell Size
                    dividedImages = mat2tiles(I, CELL_SIZE);
                    
                    %% Extract MSBS Features from each divided Cell
                    ydividedImages = size(dividedImages, 1);
                    xdividedImages = size(dividedImages, 2);
                    
                    for k = 1:ydividedImages
                        for l = 1:xdividedImages
                            currentDividedImage = dividedImages{k, l};
                            partialFeature = getHistogramFromCurrentImage(currentDividedImage, R1, R2, bin, neighborSize, distanceToNeighborCoordinates, ...
                                isUniform);
                            currentFeatures = [currentFeatures partialFeature];
                        end
                    end
                else
                    %% Extract Features from Image
                    currentFeatures = getHistogramFromCurrentImage(I, R1, R2, bin, neighborSize, distanceToNeighborCoordinates, isUniform);
                end
                
                msbsFeatures = [msbsFeatures; currentFeatures];
                msbsLabels = [msbsLabels; str2double(labelName)];
                
                %% If Cell Size Initialized, re-initialize currentFeatures Variable
                if isempty(CELL_SIZE) == 0
                    currentFeatures = [];
                end
                
                if mod(j,1000) == 0
                    fprintf('%d label scores calculated. \n', j);
                end
            end
        end
    end
end
end

function [msbsHistogram] = getHistogramFromCurrentImage(I, R1, R2, bin, neighborSize, distanceToNeighborCoordinates, isUniform)
%% Returns the MSBS Feature From Given Image

%% Get Image Size
[ysize, xsize] = size(I);

%% Get Major Patch Center Pixel.
xmajorPatchCenterPixel = R1 + 1;
ymajorPatchCenterPixel = R1 + 1;
majorPatchCenterPixel = [ymajorPatchCenterPixel, xmajorPatchCenterPixel];

%% Calculate the Major Patch Movement inside Image
majorPatchLength = (2*R1 + 1);

%% Calculate Total Movement Inside Image
ytotalMovement = ysize - majorPatchLength + 1;
xtotalMovement = xsize - majorPatchLength + 1;

%% Initialize Minor Patch Length
minorPatchLength = (2*R2 + 1);

%% Initialize MSBS Histogram
msbsHistogram = zeros(1, bin);

ycenterPixel = R2 + 1;
xcenterPixel = R2 + 1;

for i = 1:ytotalMovement
    for j = 1:xtotalMovement
        %% Get Major Patch
        yrangeMajorPatch = majorPatchCenterPixel(1) - R1 : majorPatchCenterPixel(1) + R1;
        xrangeMajorPatch = majorPatchCenterPixel(2) - R1 : majorPatchCenterPixel(2) + R1;
        majorPatch = I(yrangeMajorPatch, xrangeMajorPatch);
        
        %% Get Major Patch Coordinates
        s = size(majorPatch, 1);
        ymajorCoordinate = repmat((majorPatchCenterPixel(1) - R1:majorPatchCenterPixel(1) + R1), [s, 1])';
        xmajorCoordinate = repmat((majorPatchCenterPixel(2) - R1:majorPatchCenterPixel(2) + R1), [s, 1]);
        
        %% Get Major Patch Size
        ymajorPatch = size(majorPatch, 1);
        xmajorPatch = size(majorPatch, 2);
        
        %% Calculate Minor Patch Movement Inside Major Patch
        yminorPatchMovement = ymajorPatch - minorPatchLength + 1;
        xminorPatchMovement = xmajorPatch - minorPatchLength + 1;
        
        %% Move Inside Major Patch
        for k = 1:yminorPatchMovement
            for l = 1:xminorPatchMovement
                %% Get Major Coordinate Range
                yrangeMajorCoordinate = ymajorCoordinate(k, l) : ymajorCoordinate(k, l) + 2*R2;
                xrangeMajorCoordinate = xmajorCoordinate(k, l) : xmajorCoordinate(k, l) + 2*R2;
                
                %% Get Corresponding Spatial Coordinates
                ycoordinate = yrangeMajorCoordinate;
                xcoordinate = xrangeMajorCoordinate;
                
                %% Get Minor Patch
                minorPatch = I(ycoordinate, xcoordinate);
                
                %% Get Minor Patch Center Pixel
                minorPatchCenterPixel = minorPatch(R2 + 1, R2 + 1);
                
                %% Initialize MSBS Pattern
                msbsPattern = ones(1, neighborSize) * (-1);
                
                %% Get MSBS Pattern
                for m = 1:neighborSize
                    y = distanceToNeighborCoordinates(m, 1);
                    x = distanceToNeighborCoordinates(m, 2);
                    yneighborCoordinate = ycenterPixel + y;
                    xneighborCoordinate = xcenterPixel + x;
                    currentNeighbor = minorPatch(yneighborCoordinate, xneighborCoordinate);
                    if currentNeighbor >= minorPatchCenterPixel
                        msbsPattern(m) = 1;
                    else
                        msbsPattern(m) = 0;
                    end
                end
                
                %% Get Decimal Value
                decimalValue = 0;
                
                for m = 1:length(msbsPattern)
                    bitValue = msbsPattern(m);
                    decimalValue = decimalValue+bitValue * 2^(m - 1);
                end
                
                if isUniform == 1
                    binValue = getBinValue(decimalValue);
                else
                    binValue = decimalValue + 1;
                end
                
                msbsHistogram(binValue) = msbsHistogram(binValue) + 1;
            end
        end
        
        if j == xtotalMovement
            xmajorPatchCenterPixel = R1+1;
            ymajorPatchCenterPixel = ymajorPatchCenterPixel + 1;
        else
            xmajorPatchCenterPixel = xmajorPatchCenterPixel + 1;
        end
        
        %% Get Major Patch Center Pixel
        majorPatchCenterPixel = [ymajorPatchCenterPixel, xmajorPatchCenterPixel];
    end
end
end
