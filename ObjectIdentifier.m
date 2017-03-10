function [score, resultImage] = ObjectIdentifier(image, colorMap, shapeMap, colorWeight, shapeWeight)

%hopefully house the colorMap and shapeMap but if a function stores it =>
%data structure destroyed upon function call complete... need to add into
%DeepLearningGUI somewhere to store a map from label to the colorMap and
%shapeMap and use this to locate the object of our desire and add a box
%around it with a given score.

[h,w,dim] = size(image);
[ch, cw, cd] = size(colorMap);
[sh, sw, sd] = size(shapeMap);

inputColorMap = ColorMap(image);
colorScore = zeros(h,w);
for i= 1:cd
    colorScore = colorScore + imfilter(inputColorMap(:,:,i),colorMap(:,:,i), 'replicate');
end

%first score the image against the shape map

%then score against the color map
hit = colorWeight*colorScore;

%sum the scores together to evaluate is hit found

%return image with the hit boxed... only 1 hit per image for now...

score = zeros(h,w);
resultImage = image;