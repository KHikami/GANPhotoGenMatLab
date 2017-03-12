function [newColorMap, newShapeMap] = TrainIdentifier( ...
    origColorMap, origShapeMap, targetImage,...
    score)

%this will hold backpropagation of the error for the object identifier
%since our "ColorMap" and "ShapeMap" are our weights this will compute the
%new colorMap and shapeMap for the label

%we need to compute the derivs for ColorMap and ShapeMap.

%deriv of Color Map is stored in ColorMapDeriv

%general format: Delta_L = 2*error bitwise multiply deriv of last
%function
%Delta_l = derive of function_l bitwise multiply the weight_l times the
%delta of l+1

%new maps/weights will be a function of the calculated deltas
[sh, sw] = size(score);
thresholdMatrix = ones(sh,sw);
thresholdMatrix = thresholdMatrix*0.8;
[th, tw] = size(targetImage);

inputColorMap = ColorMap(targetImage);

%colorMapDeriv should not be the last function...
delta_2 = 2*(thresholdMatrix-score).*ones(sh,sw);

%padding


%need to pad orig color map and orig shape map to fit previous deltas
delta_1 = ColorMapDeriv(inputColorMap).*origColorMap*delta_2;

mu = 0.01; %filling in a random mu
ro = 0.05; %filling in a random ro

%if using LMS => W_n = (1-2mu*ro)W_n-1 =
%mu*delta_of_next_layer*inputdata for layer

%colorMap's new weight is origColorMap - mu*ro*origColorMap - mu*shapeMap
%delta*ColorMap(input)
newColorMap = origColorMap - mu*ro*origColorMap - mu*delta_2*inputColorMap;

%is last layer...
newShapeMap = origShapeMap;