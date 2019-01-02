function spatialCoordinates = getBestNeighborhoodSpatialCoordinates(neighborMatrix, K, R2)

spatialCoordinates(:, 1) = ones(1, K) * (-1);
spatialCoordinates(:, 2) = ones(1, K) * (-1);

idxcount = 0;

for i = 1:size(neighborMatrix, 1)
    for j = 1:size(neighborMatrix, 2)
        if neighborMatrix(i, j) == 1
            idxcount = idxcount + 1;
            spatialCoordinates(idxcount, 1) = i;
            spatialCoordinates(idxcount, 2) = j;
        end
    end
end

%% Below is Selecting Best Neighborhood in Clock-wise Direction
%{
minorPatchEdge = 2*R2+1;
minorPatchLength = minorPatchEdge;

count = 1;

for i = 1:(minorPatchEdge-1)*2
    if mod(i,4) == 1
        for j = count:minorPatchLength
            if neighborMatrix(count, j) == 1
                idxcount = idxcount + 1;
                spatialCoordinates(idxcount, 1) = count;
                spatialCoordinates(idxcount, 2) = j;
            end
        end
    end
    
    if mod(i,4) == 2
        for j = count+1:minorPatchLength
            if neighborMatrix(j, minorPatchLength) == 1
                idxcount = idxcount + 1;
                spatialCoordinates(idxcount, 1) = j;
                spatialCoordinates(idxcount, 2) = minorPatchLength;
            end
        end
    end
    
    if mod(i,4) == 3
        for j = minorPatchLength-1:-1:count
            if neighborMatrix(minorPatchLength, j) == 1
                idxcount = idxcount + 1;
                spatialCoordinates(idxcount, 1) = minorPatchLength;
                spatialCoordinates(idxcount, 2) = j;
            end
        end
    end
    
    if mod(i,4) == 0
        for j = minorPatchLength-1:-1:count+1
            if neighborMatrix(j, count) == 1
                idxcount = idxcount + 1;
                spatialCoordinates(idxcount, 1) = j;
                spatialCoordinates(idxcount, 2) = count;
            end
        end
        count = count + 1;
        minorPatchLength = minorPatchLength - 1;
    end
end
%}
end
