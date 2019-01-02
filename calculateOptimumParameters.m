function [penalty,gamma,kernelVal] = calculateOptimumParameters(trainingSet, trainingLabels, svmKernel, nfolds)
%CALCULATEOPTIMUMPARAMETERS Returns optimum C and gamma parameters for svm
%   kernel, using training set.

% grid search to find optimum C and gamma parameters of rdf kernel
% choose C and Gamma using the method proposed by
% Chih-Wei Hsu, Chih-Chung Chang, and Chih-Jen Lin
[C,G] = meshgrid(-5:2:15,-15:2:3);

if strcmp(svmKernel,'linear')
    kernelVal = 0;
elseif strcmp(svmKernel,'polynomial')
    kernelVal = 1;
elseif strcmp(svmKernel,'rbf')
    kernelVal = 2;
elseif strcmp(svmKernel,'sigmoid')
    kernelVal = 3;
end

%0 -- linear: u'*v
%1 -- polynomial: (gamma*u'*v + coef0)^degree
%2 -- radial basis function: exp(-gamma*|u-v|^2)
%3 -- sigmoid: tanh(gamma*u'*v + coef0)

%grid search, and cross-validation
cv_acc = zeros(numel(C),1);

fprintf('\n%d Fold Cross-Validation Calculation Started...\n',nfolds);
for i=1:numel(C)
    cv_acc(i) = svmtrain(trainingLabels, trainingSet, sprintf('-t %d -c %f -g %f -v %d -h 0 -q', kernelVal,2^C(i),2^G(i),nfolds));
end
fprintf('\n%d Fold Cross-Validation Calculation Ended...\n',nfolds);

% pair (C,gamma) with best accuracy
[~,idx] = max(cv_acc);

% train model with the best_C and best_gamma
penalty = 2^C(idx);
gamma = 2^G(idx);

end

