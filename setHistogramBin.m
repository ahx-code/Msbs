function bin = setHistogramBin(isUniform, K)
% Return histograms bin value

if isUniform == 1
    bin = 59;
else
    bin = 2^(K);
end

end

