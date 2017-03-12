function [result] = ColorMapDeriv(input)

%input should be a H x W x 12 since it's the derivative a color map!
%color map was of the form of an indicator function => deriv is dirac
%function

%a = color index. x = input color
%so deriv of input(:,:,1) = dirac(x-1); => returns infinity when match!
%derive of input(:,:,2) = dirac(x-2);

%not too sure if this is right...
[ih, iw, id] = size(input);
derivFunction = ones(ih,iw,id);

%not right...
for i = 1:id
%    derivFunction(:,:,i) = dirac(x-i);
end


result = derivFunction;