function [xtrain, xtest] = principalComponentAnalysis(trainingSet, testSet, isWhiteningPCA, isWhiteningPCAandDimensionalityReduction, energyPreserve)
%% PRINCIPALCOMPONENTANALYSIS Returns the principal components of Training and Test Set with 95% energy preservation.

%% Initialize Epsilon
epsilon = 1e-1;

%% Get Training Set Size
trainingSetSize = size(trainingSet, 1);

%% -Apply PCA to Training Features.-
%% 1st Take Mean of the Row Values.
X_bar = mean(trainingSet, 2);

%% 2nd Calculate Observation Number (N).
[~, N] = size(trainingSet);

%% 3rd Calculate Covariance Matrix.
S = (trainingSet - repmat(X_bar, [1, N]))*(trainingSet - repmat(X_bar, [1, N]))'.*(1/N);

%% 4th Calculate Singular Value Decomposition
% U : Left Singular Vectors
% D : Singular Values
% ~ : Right Singular Vectors
[U, D, ~] = svd(S);

if isWhiteningPCA == 1 && isWhiteningPCAandDimensionalityReduction == 0
    %% Only PCA Whitening (No Dimensionality Reduction)
    xtrain = diag(1./sqrt(diag(S) + epsilon))*trainingSet;
    xtest = diag(1./sqrt(diag(S) + epsilon))*testSet;
else
    %% 6th Reduce Dimension which preserves energy.
    diagonalVector = diag(D);
    eigenSum = trace(D);
    energy = 0;
    reducedDimension = 0;
    
    for i=1:size(diagonalVector,1)
        energy = energy+diagonalVector(i,1);
        divide = energy/eigenSum;
        if divide >= energyPreserve
            reducedDimension = i;
            break;
        end
    end
    
    if reducedDimension == 0
        error('Could not find corresponding eigen value');
    else
        fprintf('\nDimension Reduced to : %d -> %d.\n', trainingSetSize, reducedDimension);
    end
    
    G = U(:, 1:reducedDimension);
    
    if isWhiteningPCA == 1 && isWhiteningPCAandDimensionalityReduction == 1
        %% Dimensionality Reduction + Whitening
        xtrain = (diag(1./sqrt(diag(S) + epsilon))*G)'*trainingSet;
        xtest = (diag(1./sqrt(diag(S) + epsilon))*G)'*testSet;
    else
        %% Apply PCA
        xtrain = G'*trainingSet;
        xtest = G'*testSet;
    end
end
end
