function [neighborMatrix] = getBestNeighborhoods(scoreMatrix, K, R2)
%% GETBESTNEIGHBORHOODS Selects the best K highest scores from score matrix.

bestKScores = ones(1,K)*(-1);
bestKCoordinates(:,1) = ones(1,K)*(-1);
bestKCoordinates(:,2) = ones(1,K)*(-1);

vectorizedScoreMatrixY = size(scoreMatrix, 1);
vectorizedScoreMatrixX = size(scoreMatrix, 2);

neighborMatrix = zeros(2*R2+1, 2*R2+1);

vectorCounter = 1;
vectorizedScoreMatrix = zeros(1, (2*R2+1)*(2*R2+1) - 1);

for i = 1:vectorizedScoreMatrixY
    for j = 1:vectorizedScoreMatrixX
        %% if current pixel is not center pixel
        if ~(i == R2 + 1 && j == R2 + 1)
            vectorizedScoreMatrix(vectorCounter) = scoreMatrix(i, j);
            vectorCounter = vectorCounter + 1;
        end
    end
end

highToLowScores = sort(vectorizedScoreMatrix, 'descend');

%% Get Best K Value from highToLowScores Vector.
for i = 1:K
    bestKScores(i) = highToLowScores(i);
end

idx = 1;

for i = 1:K
    currentBestValue = bestKScores(i);
    alreadyInside = 0;
    
    for j = 1:vectorizedScoreMatrixY
        for k = 1:vectorizedScoreMatrixX
            
            if currentBestValue == scoreMatrix(j, k) && alreadyInside == 0
                %% Check whether j and k stored before.
                isStored = find( j == bestKCoordinates(:, 1) & k == bestKCoordinates(:, 2), 1);
                
                if isempty(isStored) == 1
                    bestKCoordinates(idx, 1) = j;
                    bestKCoordinates(idx, 2) = k;
                    idx = idx+1;
                    alreadyInside = 1;
                end
            end
        end
    end
end

for i = 1:size(bestKCoordinates, 1)
    ycoord = bestKCoordinates(i,1);
    xcoord = bestKCoordinates(i,2);
    neighborMatrix(ycoord, xcoord) = 1;
end
end
