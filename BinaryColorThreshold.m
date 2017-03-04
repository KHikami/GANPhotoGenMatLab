function [value] = BinaryColorThreshold(colorVar, input)

%input = input image and it will filter out the pixels that have the color
%that's within the ranges. (returns a 1 for those pixels)
%takes in the color it is comparing to.

%Using HSV (See google doc Color Ranges and Values for new ranges)

hsvInput = rgb2hsv(input);

%hue values are returned as a decimal from 0-1 so multiplying by 360 to be
%integer values that hue table uses
hsvInput(:,:,1) = hsvInput(:,:,1) .* 360;

switch(colorVar)
    case 'White'
        resultIndices = find(and(hsvInput(:,:,3) > 0.95, hsvInput(:,:,2) < 0.1));
    case 'Black'
        resultIndices = find(and(hsvInput(:,:,3) < 0.2, hsvInput(:,:,2) < 0.1));
    case 'Gray'
        whiteIndices = find(and(hsvInput(:,:,3) > 0.95, hsvInput(:,:,2) < 0.1));
        %want those that are gray but not light enough to be white
        resultIndices = setdiff(find(and(hsvInput(:,:,3) >= 0.2, hsvInput(:,:,2) < 0.1)), whiteIndices);
    case 'Red'
        hueIndices = find(or(hsvInput(:,:,1) < 30, hsvInput(:,:,1) >= 345));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(hsvInput(:,:,2) >= 0.5);
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Pink'
        hueIndices = find(or(hsvInput(:,:,1) < 30, hsvInput(:,:,1) >= 345));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(and(hsvInput(:,:,2) < 0.5, hsvInput(:,:,2) >= 0.1));
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Orange'
        hueIndices = find(and(hsvInput(:,:,1) < 60, hsvInput(:,:,1) >= 30));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(hsvInput(:,:,2) >= 0.5);
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Brown'
        hueIndices = find(and(hsvInput(:,:,1) < 60, hsvInput(:,:,1) >= 30));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(and(hsvInput(:,:,2) < 0.5, hsvInput(:,:,2) >= 0.1));
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Yellow'
        hueIndices = find(and(hsvInput(:,:,1) < 75, hsvInput(:,:,1) >= 60));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(hsvInput(:,:,2) >= 0.1);
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Green'
        hueIndices = find(and(hsvInput(:,:,1) < 165, hsvInput(:,:,1) >= 75));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(hsvInput(:,:,2) >= 0.1);
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Blue'
        hueIndices = find(and(hsvInput(:,:,1) < 270, hsvInput(:,:,1) >= 165));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(hsvInput(:,:,2) >= 0.1);
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Purple'
        hueIndices = find(and(hsvInput(:,:,1) < 300, hsvInput(:,:,1) >= 270));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(hsvInput(:,:,2) >= 0.1);
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
    case 'Magenta'
        hueIndices = find(and(hsvInput(:,:,1) < 345, hsvInput(:,:,1) >= 300));
        lightIndices = find(hsvInput(:,:,3) >= 0.2);
        satIndices = find(hsvInput(:,:,2) >= 0.1);
        resultIndices =intersect(intersect(hueIndices,lightIndices),satIndices);
end
[h,w,z] = size(hsvInput);

%have to put it into the size of the original because if not, it will warp
%it into a h by w*z matrix :(
results = zeros(h,w,z);

results(resultIndices) = 1;

value = results(:,:,1);

