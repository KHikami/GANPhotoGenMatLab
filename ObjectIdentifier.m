function [score, resultbox, hasObject] = ObjectIdentifier(image, colorMap, shapeMap)

%hopefully house the colorMap and shapeMap but if a function stores it =>
%data structure destroyed upon function call complete... need to add into
%DeepLearningGUI somewhere to store a map from label to the colorMap and
%shapeMap and use this to locate the object of our desire and add a box
%around it with a given score.
h = size(image,1);
w = size(image,2);
[ch, cw, cd] = size(colorMap);
hasObject = 1;


inputColorMap = ColorMap(image);
colorScore = zeros(size(inputColorMap,1),size(inputColorMap,2));
%score image against colormap (stored colormap is the color weight)

%had to normalize the input colormap... since max value is 1 for every spot
%=> normalize by the number of 1 possible.
colorFilter = zeros(ch,cw,cd);
for i = 1:cd
    numToDivideBy = size(colorMap(:,:,i),1)*size(colorMap(:,:,i),2);
   %numToDivideBy = sum(reshape(colorMap(:,:,i),1, size(colorMap(:,:,i),1)*size(colorMap(:,:,i),2)));
   if(numToDivideBy == 0)
       numToDivideBy = 1;
   end
   colorFilter(:,:,i) = colorMap(:,:,i)/numToDivideBy;
end
for i= 1:cd
    colorScore = colorScore + imfilter(inputColorMap(:,:,i),colorFilter(:,:,i), 'replicate');
    %imfilter has a conv feature as well but this one is weird in which it
    %keeps giving me positive numbers
    %colorScore = colorScore + inputColorMap(:,:,i) .* colorMap (:,:,i);
end

%score the output of colorScore/pixelize(ColorMap()) against the shape map

%return image with the hit boxed... only 1 hit per image for now...

threshold = 0.8;%to be tweaked as we go along... currently too low from results...
score = colorScore;  %should get the result after shape Score calculated
%right now setting it to colorScore

[val, ind] = sort(colorScore(:), 'descend');

%we only want the topmost hit.
%check if top hit is above threshold
%if is => map to pixel coordinates & draw box in image
%  return image with box
%score will be the sub matrix of score for the boxed section

topIndex = ind(1);
box = [];
if(val(1) >= threshold)
    position = (1:(size(score,1))*(size(score,2)));
    position = reshape(position, size(score,1), size(score,2));
    [yblock, xblock] = find(position == topIndex);
    assert(val(1)==score(yblock,xblock));

    %since we scaled by 8 for our blocks => undoing the scale
    ypixel = yblock*8;
    xpixel = xblock*8;

    %draw rectangle around identified object (not too sure how to stuff
    %this into the image)
    %want the box to be around the size of our template
    %suggested is to save it into an image and display it later but :/
    
    %storing the box coordinates (should be where the object is in the
    %image but currently having the problem with imfilter)(gets cropped off
    %in axes mode...) Not much point to this right now since the compressed image
    %is stored in colormap...
    boxwidth = max([cw*8-3 w-3]);
    boxheight = max([ch*8-3 h-3]);
    box = [xpixel ypixel boxwidth boxheight];
    
else
    %value not high enough for detection => return fail...
    hasObject = 0;
end

resultbox = box;

