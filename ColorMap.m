%This should generate our color mapp... eventually... one day...

function [ Result ] = ColorMap(Image)
%turning the image into blobs of color :)
[origH, origW] = size(Image);

sizeOfSections = 8; %our pixel blocks square size :)

miniMapH = ceil(origH/sizeOfSections); %num of pixel blocks in Y direction
miniMapW = ceil(origW/sizeOfSections); %num of pixel blocks in X direction

%First split the image into 10 matrices based on if they have a specific
%color in that pixel => 1
%Trace 8 by 8 patch of each of the 10 matrices and have total stored in
%respective cell
%Majority number wins.
%Resulting color map will be the downsized version re-expanded (the 1
%square gets mapped to collection of 64 squares)

%error here about the dimensions of the matrices being concatenated are not
%consistent.
colorStructure = ['Red'; 'Orange'; 'Yellow'; 'Blue'; 'Pink'; 'Green'; 'Purple'; 'Brown'; 'Black'; 'White'];
numOfColors = size(colorStructure);
colorMiniMap = zeros(miniMapH, miniMapW, numOfColors); 

for i = 1:numOfColors
   %for each of the number of colors I have, I'm going to check if the
   %pixel is in that color range. and put a 1 if it is. 0 else wise
   
   %I then map into resulting minimap for every 8 the trace of this 8 by 8
   %section
   
   colorResult = BinaryColorThreshold(colorStructure(i), Image);
   
   %grabs an array of 8 by 8 blocks from colorResult
   colorBlock = im2col(colorResult,[sizeOfSection sizeOfSection], 'distinct');
   
   %does the trace/sum per colorBlock
   hitCount = sum(colorBlock);
   
   %maps the sums of each block into the minimap shape
   resultMiniMap = reshape(hitCount, miniMapH, miniMapW);
   
   %store the minimap of the color subsection into colorMiniMap
   colorMiniMap(:,:,i) = resultMiniMap;
    
end

%need to then expand minimap to show a pixelized version of original image
%basically "undo" the block function but fill the values with the
%respective color of the result

%there's a function col2im that rearranges the column matrix into blocks of
%m by n, to then fit an overal size matrix of [mm nn], with setting
%'distinct'

%keeping the 10 separate layers for probability calculation later...

Result = Image;