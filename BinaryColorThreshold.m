function [value] = BinaryColorThreshold(colorVar, input)

%input = input image and it will filter out the pixels that have the color
%that's within the ranges. (returns a 1 for those pixels)
%takes in the color it is comparing to.

%Using HSV (See google doc Color Ranges and Values for new ranges)

hsvInput = rgb2hsv(input);

%hue values are returned as a decimal from 0-1 so multiplying by 360 to be
%integer values that hue table uses
hsvInput = hsvInput(:,1) .* 360;

switch(colorVar)
    case 'White'
        resultIndices = find(isWhite(hsvInput));
    case 'Black'
        resultIndices = find(isBlack(hsvInput));
    case 'Gray'
        resultIndices = find(isGray(hsvInput) && not(isBlack(hsvInput)&& not(isWhite(hsvInput))));
    case 'Red'
        validIndices = find(not(isBlack(hsvInput)) && not(isWhite(hsvInput)) && not(isGray(hsvInput)));
        hueIndices = find(hsvInput(:,1) < 30 || hsvInput(:,1) >= 345);
        %already know it's greater than or equal to 0.2 for value and >=30 for
        %saturation
        lightIndices = find(hsvInput(:,3) < 0.8);
        resultIndices = setdiff(lightIndices,(setdiff(validIndices,hueIndices)));
    case 'Pink'
        validIndices = find(not(isBlack(hsvInput)) && not(isWhite(hsvInput)) && not(isGray(hsvInput)));
        hueIndices = find(hsvInput(:,1) < 30 || hsvInput(:,1) >= 345);
        lightIndices = find(hsvInput(:,3) >= 0.8);
        resultIndices = setdiff(lightIndices,(setdiff(validIndices,hueIndices)));
    case 'Orange'
        validIndices = find(not(isBlack(hsvInput)) && not(isWhite(hsvInput)) && not(isGray(hsvInput)));
        hueIndices = find(hsvInput(:,1) >= 30 && hsvInput(:,1) < 60);
        %already know light is less than or equal to 95
        lightIndices = find(hsvInput(:,3) >= 0.45);
        resultIndices = setdiff(lightIndices,(setdiff(validIndices,hueIndices)));
    case 'Brown'
        validIndices = find(not(isBlack(hsvInput)) && not(isWhite(hsvInput)) && not(isGray(hsvInput)));
        hueIndices = find(hsvInput(:,1) >= 30 && hsvInput(:,1) < 60);
        %already know light is greater than  or equal to 20
        lightIndices = find(hsvInput(:,3) < 0.45);
        resultIndices = setdiff(lightIndices,(setdiff(validIndices,hueIndices)));
    case 'Yellow'
        %TO-DO
    case 'Green'
        %TO-DO
    case 'Blue'
        %TO-DO
    case 'Purple'
        %TO-DO
    case 'Magenta'
        %TO-DO
end
[h,w] = size(hsvInput);

value = zeros(h,w);

value(resultIndices) = 1;

function [bool] = isWhite(hsv)
if(hsv(:,3) > 0.95)
    bool = true;
else
    bool = false;
end

function [bool] = isBlack(hsv)
if(hsv(:,3) < 0.2)
    bool = true;
else
    bool = false;
end

function [bool] = isGray(hsv)
if(hsv(:,2) < 0.3)
    bool = true;
else
    bool = false;
end