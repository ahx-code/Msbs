function [saveTemplate, saveNeighbor, saveTrainingFeatures, saveTestFeatures, savePcaFeatures] = setFileNames(R1, R2, K, CELL_SIZE)

R1String = num2str(R1);
R2String = num2str(R2);
KString = num2str(K);
yCELL_SIZE = num2str(CELL_SIZE(1));
xCELL_SIZE = num2str(CELL_SIZE(2));

if isempty(CELL_SIZE)
    fileTemplate = strcat('Msbs_r1_', R1String, '_r2_', R2String, '_k_', KString);
else
    fileTemplate = strcat('Msbs_r1_', R1String, '_r2_', R2String, '_k_', KString, '_CellSize_', yCELL_SIZE, 'x', xCELL_SIZE);
end

saveTemplate = strcat(fileTemplate, '_score_template.mat');
saveNeighbor = strcat(fileTemplate, '_neighbor.mat');
saveTrainingFeatures = strcat(fileTemplate, '_trainingFeatures.mat');
saveTestFeatures = strcat(fileTemplate, '_testFeatures.mat');
savePcaFeatures = strcat(fileTemplate, '_Pca_features.mat');

end

