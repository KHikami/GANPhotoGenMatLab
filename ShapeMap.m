%one day this will generate our ShapeMap... one day...

function [ Result ] = ShapeMap(Image)

%turning the image to grayscale so 1 = high saturation, 0 = low saturation
%easier to calculate the contrast derivatives from here

grayScale = im2double(rgb2gray(Image));
%imshow(grayScale);

numberOfSections = 8; %technically is number of sections ^ (1/2)

[grayH, grayW] = size(grayScale);

blockH = ceil(grayH/numberOfSections);
blockW = ceil(grayW/numberOfSections);

numOfOrientationDirections = 9; %splitting the 180 possible gradiants into 9-10 major ones
binsRange = linspace(-pi/2, pi/2, numOfOrientationDirections+1);

%gradient is calculated with (X2-X1)/(Y2-Y1) in 1 direction thus:
filterX = [-1 1]; %row vector
filterY = [-1; 1]; %column vector

gradientX = imfilter(grayScale, filterX, 'replicate');
gradientY = imfilter(grayScale, filterY, 'replicate');

%calculate the magnitude and orientation of the gradient at each pixel
magnitude = (gradientX.*gradientX + gradientY.*gradientY).^(1/2);
orientation = atan(gradientX./gradientY);

%imshow(magnitude);

%my orig code looped over the number of orientation bins and stored a
%magnitued per direction... doesn't seem very optimal... in the process of
%rethinking this...

%pick a threshold for the magnitude to be to keep it. Currently set to be
%0.1 * the max magnitude I can find
threshold = 0.1*(max(magnitude(:)));

%create final image result...                                                               

Result = Image;