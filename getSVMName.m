function filename = getSVMName(penalty, gamma, kernelValue, R1, R2, K, downsampleRatio, isPca, isWhitenedPCA, isWhiteningPCAandDimensionalityReduction)
%% GETSVMNAME Returns file save name based on penalty, gamma and kernel.

penaltyString = num2str(penalty);
gammaString = num2str(gamma);
kernalValueString = num2str(kernelValue);
R1String = num2str(R1);
R2String = num2str(R2);
KString = num2str(K);
downsampleRatioString = num2str(downsampleRatio);

if R1 ~= 0 && R2 ~= 0 && K ~= 0
    filename = strcat('Msbs_r1_', R1String, '_r2_', R2String, '_k_', KString, '_c_', penaltyString, '_g_', gammaString, '_', kernalValueString);
else
    filename = strcat('Msbs_c_', penaltyString, '_g_', gammaString, '_', kernalValueString);
end

if downsampleRatio ~= 0
    filename = strcat(filename, '_downsampled_', downsampleRatioString);
end

if isWhitenedPCA == 1 && isWhiteningPCAandDimensionalityReduction == 0
    filename = strcat(filename, '_whitening_pca');
elseif isWhitenedPCA == 1 && isWhiteningPCAandDimensionalityReduction == 1
    filename = strcat(filename, '_whitening_pca_dimensionalityReduced');
elseif isPca == 1
    filename = strcat(filename, '_pca');
end
end
