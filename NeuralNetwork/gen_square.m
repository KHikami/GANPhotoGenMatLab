function C = gen_square(radius, x_c, y_c, im_size)
%GEN_CIRCLE Generate a square 

[x, y] = meshgrid(1:im_size, 1:im_size);
C = radius <= abs(x-x_c)+abs(y-y_c) & abs(x-x_c)+abs(y-y_c) <= radius+1;

end

