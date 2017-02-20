function [score, resultImage] = ObjectIdentifier(filename, colorMap, shapeMap)

%hopefully house the colorMap and shapeMap but if a function stores it =>
%data structure destroyed upon function call complete... need to add into
%DeepLearningGUI somewhere to store a map from label to the colorMap and
%shapeMap and use this to locate the object of our desire and add a box
%around it with a given score.

image = imread(filename);
[h,w] = size(image);

%first score the image against the shape map

%then score against the color map

%sum the scores together to evaluat is hit found

%return image with the hit boxed... only 1 hit per image for now...

score = zeros(h,w);
resultImage = image;