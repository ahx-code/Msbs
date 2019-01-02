function [xtrain_scaled,xtest_scaled] = scaleSet(xtrain,xtest)
%SCALESET Returns scaled Training and Test Set.
%   Scaling method is Max-Min Scaling.

% find the minimums and range for Max- Min feature scaling
minimums = min(xtrain, [], 1, 'omitnan');
ranges = max(xtrain, [], 1) - minimums;

% scale both train and test data
xtrain_scaled = (xtrain - repmat(minimums, size(xtrain, 1), 1)) ./ repmat(ranges, size(xtrain, 1), 1);
xtest_scaled = (xtest - repmat(minimums, size(xtest, 1), 1)) ./ repmat(ranges, size(xtest, 1), 1);

end

