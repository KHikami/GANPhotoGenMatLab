function [newColorMap, newShapeMap] = TrainIdentifier( ...
    origColorMap, origShapeMap, targetImage,...
    score)

%this will hold backpropagation of the error for the object identifier
%since our "ColorMap" and "ShapeMap" are our weights this will compute the
%new colorMap and shapeMap for the label

%we need to compute the derivs for ColorMap and ShapeMap... ColorMap is
%not differentiable though... umm...
% anyways, newColorMap is a function of origColorMap but under which
% function depends on our risk...

%general format: Delta_L = 2*error bitwise multiply deriv of last
%function
%Delta_l = derive of function_l bitwise multiply the weight_l times the
%delta of l+1

%new maps/weights will be a function of the calculated deltas

newColorMap = origColorMap;
newShapeMap = origShapeMap;