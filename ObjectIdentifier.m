function [score, resultbox, hasObject] = ObjectIdentifier(image, colorMap, shapeMap)

%hopefully house the colorMap and shapeMap but if a function stores it =>
%data structure destroyed upon function call complete... need to add into
%DeepLearningGUI somewhere to store a map from label to the colorMap and
%shapeMap and use this to locate the object of our desire and add a box
%around it with a given score.

[ih, iw, ~] = size(image);
[ch, cw, cd] = size(colorMap);
hasObject = 1;


inputColorMap = ColorMap(image);

%The color map and input will most likely have a slight difference or large
%pad our original colormap such that where if the input is bigger => pad
%with a 0 (we'll go through the NANs and turn them into 0s)

%zeroPad function:
[colorMap, inputColorMap] = PadInputs(colorMap, inputColorMap);


colorScore = zeros(size(inputColorMap,1),size(inputColorMap,2));
%score image against colormap (stored colormap is the color weight)
%p(color at input) = input color map
%p(color in target) = color map
%we want to store the probability is target based on color at input given
%right now storing p(color in input AND color in target)
%color in target
for i= 1:cd
    tempScores = inputColorMap(:,:,i) .* colorMap (:,:,i);
    tempScores(isnan(tempScores))= 0;
    colorScore = colorScore + tempScores;
end

%score the output of colorScore/pixelize(ColorMap()) against the shape map

%return image with the hit boxed... only 1 hit per image for now...

threshold = 0.8;%to be tweaked as we go along... currently too low from results...
score = colorScore;  %should get the result after shape Score calculated
%right now setting it to colorScore

[val, ind] = sort(colorScore(:), 'descend');

%we check the median score => if greater than thresh more than 50% correct!
middle = size(ind,1)/2;
midIndex = ind(middle);
box = [];

if(val(midIndex) >= threshold)
    position = (1:(size(score,1))*(size(score,2)));
    position = reshape(position, size(score,1), size(score,2));
    [yblock, xblock] = find(position == midIndex);

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
    boxwidth = max([cw*8-3 iw-3]);
    boxheight = max([ch*8-3 ih-3]);
    box = [xpixel ypixel boxwidth boxheight];
    
else
    %value not high enough for detection => return fail...
    hasObject = 0;
end

resultbox = box;

