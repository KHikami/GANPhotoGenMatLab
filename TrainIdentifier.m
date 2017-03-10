function [newColorWeight, newShapeWeight, newColorMap, newShapeMap] = TrainIdentifier( ...
    origColorMap, origShapeMap, origColorWeight, origShapeWeight, targetColor, targetShape,...
    score)

%this will hold back propagation of the error for the object identifier

%currently doing something not right :P
newColorWeight = origColorWeight;
newShapeWeight = origShapeWeight;
newColorMap = origColorMap;
newShapeMap = origShapeMap;