function downsampledImage = downsampleImage(inputImage, downsampleRatio)

yimage = size(inputImage, 1);
ximage = size(inputImage, 2);

downRatio = [downsampleRatio downsampleRatio];

if downRatio(1) ~= yimage || downRatio(2) ~= ximage
    downsampledImage = imresize(inputImage,downRatio);
end
end