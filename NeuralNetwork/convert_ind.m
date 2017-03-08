function sub = convert_ind( ind )
%CONVERT_IND Summary of this function goes here
%   Detailed explanation goes here
sub = cells(3,1);

[sub(1),sub(2),sub(3)] = ind2sub(ind);

end

