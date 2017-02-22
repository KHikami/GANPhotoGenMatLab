function [value] = BinaryColorThreshold(colorVar, input)

%input = input image and it will filter out the pixels that have the color
%that's within the ranges. (returns a 1 for those pixels)
%takes in the color it is comparing to.

%RGB ranges for the colors... (have a site for this)
%Pink ranges from [255, 204, 204] to [255, 153, 153]
%Red ranges from [255,102,102] to [153, 0, 0]
%Orange ranges from [255,229,204] to [255,128,0]
%Yellow ranges from [255, 255, 204] to [255,255,0]
%Green [229, 255, 204] to [0,153,76]
%Blue [204, 255, 255] to [0, 0, 153]
%Purple [229, 204, 255] to [153, 0, 153]
%Brown 
%Black
%White [255, 255, 255]
%RGB is not linear... so the values below are "estimates" can easily change
%this to another system if we find a better one...

switch(colorVar)
    case 'Red'
        minRedThresh = 204;
        minGreenThresh = 0;
        minBlueThresh = 0;
        maxRedThresh = 255;
        maxGreenThresh = 102;
        maxBlueThresh = 102;
    case 'Pink' %very very close to red... not too sure if I want to change the spectrum
        minRedThresh = 255;
        minGreenThresh = 153;
        minBlueThresh = 153;
        maxRedThresh = 255;
        maxGreenThresh = 204;
        maxBlueThresh = 229;
    case 'Orange'
        minRedThresh = 255;
        minGreenThresh = 128;
        minBlueThresh = 0;
        maxRedThresh = 255;
        maxGreenThresh = 229;
        maxBlueThresh = 204;
    case 'Yellow'
        minRedThresh = 255;
        minGreenThresh = 255;
        minBlueThresh = 0;
        maxRedThresh = 255;
        maxGreenThresh = 255;
        maxBlueThresh = 204;
    case 'Blue'
        minRedThresh = 0;
        minGreenThresh = 0;
        minBlueThresh = 255;
        maxRedThresh = 204;
        maxGreenThresh = 255;
        maxBlueThresh = 255;
    case 'Green'
        minRedThresh = 0;
        minGreenThresh = 204;
        minBlueThresh = 0;
        maxRedThresh = 204;
        maxGreenThresh = 255;
        maxBlueThresh = 229;
    case 'Brown'
        minRedThresh = 102;
        minGreenThresh = 0;
        minBlueThresh = 0;
        maxRedThresh = 153;
        maxGreenThresh = 76;
        maxBlueThresh = 0;
    case 'Black'
        minRedThresh = 0;
        minGreenThresh = 0;
        minBlueThresh = 0;
        maxRedThresh = 51;
        maxGreenThresh = 51;
        maxBlueThresh = 51;
    case 'Purple'
        minRedThresh = 153;
        minGreenThresh = 0;
        minBlueThresh = 153;
        maxRedThresh = 255;
        maxGreenThresh = 204;
        maxBlueThresh = 255;
    case 'White'
        minRedThresh = 255;
        minGreenThresh = 255;
        minBlueThresh = 255;
        maxRedThresh = 255;
        maxGreenThresh = 255;
        maxBlueThresh = 255;
end

[l,w] = size(input);
value = zeros(l,w);

maxRedIndices = find(input(1) <= maxRedThresh);
maxGreenIndices = find(input(2) <= maxGreenThresh);
maxBlueIndices = find(input(3) <= maxBlueThresh);
minRedIndices = find(input(1) >= minRedThresh);
minGreenIndices = find(input(2) >= minGreenThresh);
minBlueIndices = find(input(3) >= minBlueThresh);

overlappingRedIndices = setdiff(maxRedIndices,minRedIndices);
overlappingGreenIndices = setdiff(maxGreenIndices, minGreenIndices);
overlappingBlueIndices = setdiff(maxBlueIndices, minBlueIndices);

finalIndices = setdiff(setdiff(overlappingRedIndices, overlappingGreenIndices),overlappingBlueIndices);

value(finalIndices) = 1;

