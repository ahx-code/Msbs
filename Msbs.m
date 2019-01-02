%% Author : Ahmet Tavli
%% Aim : Get MSBS features from both Train and Test Sets, feed to SVM.
%% Date : November 16, 2017
%% Update-1 : February 6, 2018
%% Update-2 : February 16, 2018

clear;
clc;

%% Path Parameters
%
DATASET_FOLDER_NAME = 'Datasets';
DATASET_NAME = 'Designed_ExtendedYaleB/ExtendedYaleB_prep';
TRAINING_FOLDER_NAME = 'Gallery/Subset1';
TEST_FOLDER_NAME = 'Probes/Subset2';
ORIGINAL_DATASET_NAME = 'ExtendedYaleB_PreprocessedChainApplied';  % Unpartitioned DataSet
%}

%% MSBS Parameters
R1 = 2;
R2 = 1;
K = 4;

%% SVM Parameters
useSvm = 1;
svmKernel = 'linear';  % linear, polynomial, rbf
scaleDataset = 0;  % scale dataset ?
useLibSvm = 1;

%% PCA Parameters
isPca = 0;
isWhitenedPCA = 0; % Must check isPca
isWhitenedPCAandDimensionalityReduction = 0;
energyPreserve = 0.95;

if isWhitenedPCA == 1
    isPca = 1;
end

%% Classification Improvement Parameters
n_folds = 10;
isUniform = 0;
downsampleRatio = 0;  % if 0 don't apply downsampling to image.
CELL_SIZE = [7 7];

%% Set Platform
isDeep2 = 1;
normalizeTrainingAndTestFeatures = 0;

%% Assuming All Images in Dataset have same height and width
imageHeight = 192;
imageWidth = 168;

%% Set Paths
[originalDatasetPath, trainPath, testPath] = setPaths(DATASET_FOLDER_NAME, ORIGINAL_DATASET_NAME, DATASET_NAME, TRAINING_FOLDER_NAME, TEST_FOLDER_NAME, ...
    isDeep2);

%% Set Bins
bin = setHistogramBin(isUniform, K);

%% Check Whether K Neighbor can be selected from Minor Patch
checkKSuitability(K, R2)

%% Set File Names
[saveTemplate, saveNeighbor, saveTrainingFeatures, saveTestFeatures, savePcaFeatures] = setFileNames(R1, R2, K, CELL_SIZE);

%% Initialize Training and Test Features
trainingFeatures = []; trainingLabels = []; testFeatures = []; testLabels = [];

%% Get Dataset Size
datasetSize = getDatasetSize(originalDatasetPath);
trainingSetSize = getDatasetSize(trainPath);
testSetSize = getDatasetSize(testPath);

%% Part #1 : Get Neighborhood Template
if exist(saveTemplate, 'file')
    fprintf('\nLoading %s...\n', saveTemplate);
    load(saveTemplate);
    elser
    scoreMatrix = getNeighborhoodTemplate(originalDatasetPath, R1, R2, downsampleRatio, imageHeight, imageWidth, datasetSize);
    save(saveTemplate,'scoreMatrix');
    fprintf('\nThe %s has saved...\n',saveTemplate);
end

%% Part #2 : Get Best Neighborhoods
if exist(saveNeighbor,'file')
    fprintf('\nLoading %s...\n', saveNeighbor);
    load(saveNeighbor);
else
    neighborMatrix = getBestNeighborhoods(scoreMatrix, K, R2);
    spatialCoordinates = getBestNeighborhoodSpatialCoordinates(neighborMatrix, K, R2);
    save(saveNeighbor, 'neighborMatrix', 'spatialCoordinates');
    fprintf('\nThe %s has saved...\n', saveNeighbor);
end

%% Part #3 :Get MSBS Features
%% Get Training Features
if exist(saveTrainingFeatures, 'file')
    fprintf('\nLoading %s...\n', saveTrainingFeatures);
    load(saveTrainingFeatures);
else
    [trainingFeatures, trainingLabels] = getMSBSFeatures(trainPath, bin, R1, R2, spatialCoordinates, isUniform, downsampleRatio, CELL_SIZE);
    save(saveTrainingFeatures, 'trainingFeatures', 'trainingLabels');
    fprintf('\nThe %s has saved...\n', saveTrainingFeatures);
end

%% Get Test Features
if exist(saveTestFeatures, 'file')
    fprintf('\nLoading %s...\n', saveTestFeatures);
    load(saveTestFeatures);
else
    [testFeatures, testLabels] = getMSBSFeatures(testPath, bin, R1, R2, spatialCoordinates, isUniform, downsampleRatio, CELL_SIZE);
    save(saveTestFeatures, 'testFeatures', 'testLabels');
    fprintf('\nThe %s has saved...\n', saveTestFeatures);
end

%% Optional Part : Normalize Training and Test Features
if normalizeTrainingAndTestFeatures == 1
    trainingFeatures = trainingFeatures ./ length(trainingFeatures);
    testFeatures = testFeatures ./ length(testFeatures);
end

%% Optional Part : Scale Set (Training and Test Sets)
if scaleDataset == 1
    [trainingFeatures, testFeatures] = scaleSet(trainingFeatures, testFeatures);
end

%% Optional Part : PCA
if isPca == 1
    if exist(savePcaFeatures, 'file')
        fprintf('\nLoading %s...\n', savePcaFeatures);
        load(savePcaFeatures);
    else
        trainingFeatures = trainingFeatures';
        testFeatures = testFeatures';
        
        [trainingFeatures, testFeatures] = principalComponentAnalysis(trainingFeatures, testFeatures, isWhitenedPCA, isWhitenedPCAandDimensionalityReduction, ...
            energyPreserve);
        
        trainingFeatures = trainingFeatures';
        testFeatures = testFeatures';
        
        save(savePcaFeatures,'trainingFeatures','testFeatures');
    end
end

%% Part# 4 : Training and Prediction
if useSvm == 0
    %% Part# 5 : NNC
    testFeatures = testFeatures';
    trainingFeatures = trainingFeatures';
    
    nearestNeighborClassifierAccuracy = classifyNN(testFeatures, trainingFeatures, testLabels, trainingLabels);
    nearestNeighborClassifierAccuracyPercentage = nearestNeighborClassifierAccuracy*100;
    nearestNeighborClassifierAccuracyPercentageString = num2str(nearestNeighborClassifierAccuracyPercentage);
    
    svmMessage = ['NCC Accuracy : ', nearestNeighborClassifierAccuracyPercentageString, '%%\n']; fprintf(svmMessage);
else
    %% Part# 5 : Train and Predict Using SVM
    if useLibSvm == 1
        %% Add LIB-SVM to the path
        svmPath = strcat('/HOME/ahmet.tavli/Documents/MATLAB/libsvm-3.22/matlab'); addpath(svmPath);
        
        %% Calculate Optimum Parameters
        [bestC, bestG, kernelVal] = calculateOptimumParameters(trainingFeatures, trainingLabels, svmKernel, n_folds);
        
        %% Print the Best Penalty and Gamma Values
        fprintf('\nBest C Value : is %.6f \n',bestC);
        fprintf('\nBest Gamma Value : is %.6f \n',bestG);
        
        %% Get Save Names
        saveName = getSVMName(bestC, bestG, svmKernel, R1, R2, K, downsampleRatio, isPca, isWhitenedPCA, isWhitenedPCAandDimensionalityReduction);
        saveNameMat = strcat(saveName,'.mat');
        
        %% SVM
        if exist(saveNameMat,'file')
            fprintf('\nLoading file %s ...\n',saveNameMat);
            load(saveNameMat);
        else
            %% Set SVM Parameters
            svmParameters = sprintf('-t %d -c %f -g %f -h 0 -q', kernelVal, bestC, bestG);
            
            %% Get SVM Model
            svmModel = svmtrain(trainingLabels, trainingFeatures, svmParameters);
            
            %% Calculate SVM Accuracy
            [~, svmAccuracy, ~] = svmpredict(testLabels, testFeatures, svmModel, '-q');
            
            %% Save Classification Accuracy
            svmAccuracyString = num2str(svmAccuracy(1));
            svmMessage = ['Penalty: ', num2str(bestC), ' Gamma:', num2str(bestG), ' ', svmKernel, ' Kernel Accuracy: ', svmAccuracyString, '%%\n'];
            saveName = strcat(saveName, '_', num2str(svmAccuracy(1)), '%.mat');
            save(saveName); fprintf(svmMessage);
        end
    else
        rng(1); % For reproducibility
        t = templateSVM('Standardize',1,'KernelFunction','linear');
        svmModel = fitcecoc(trainingFeatures, trainingLabels, 'Learners', t, 'FitPosterior',1);
        rloss = resubLoss(svmModel);
        P = predict(svmModel, testFeatures);
        C = 0;
        
        for i = 1:numel(P)
            if P(i) == testLabels(i)
                C=C+1;
            end
        end
        
        svmMessage = (C*100) / numel(P); fprintf('\nAccuracy: %.4f%%\n', svmMessage);
    end
end
