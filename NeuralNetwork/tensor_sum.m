function out = tensor_sum(x,y)
%TENSOR_SUM computes the sensor sum of column vectors x and y
out = reshape(bsxfun(@plus, y, x'), [numel(x)*numel(y), 1]);

end

