%This should generate our color mapp... eventually... one day...

function [ Result ] = ColorMap(Image)
%turning the image into blobs of color :)
[origH, origW] = size(Image);

sizeOfSections = 8; %our pixel blocks square size :)

pixelBlockH = ceil(origH/sizeOfSections); %num of pixel blocks in Y direction
pixelBlockW = ceil(origW/sizeOfSections); %num of pixel blocks in X direction

% I want color of the block to be the majority color in the pixel block
% E.g. if in the pixel block the majority is red => entire block is colored
% red

%function imfilter with option 'replicate' will cover the image block per
%block
%example use: dx = imfilter(I, hdx, 'replicate') where hdx = our filter, I
%is our image

%images in matlab info: https://www.mathworks.com/help/matlab/ref/image-properties.html?searchHighlight=pixelate%20image&s_tid=doc_srchtitle

colorFilter = zeros(sizeOfSections, sizeOfSections); 
%generates a new filter will all 0s in the size of our patch



Result = Image;