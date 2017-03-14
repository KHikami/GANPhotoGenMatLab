%will generate a painted image with a given label and call the object
%identifier to check against it

function [ Painting ] = GenerateImage(generator, vector, score)

Painting = imread('GoogleImages/GoogleVDay.jpg');