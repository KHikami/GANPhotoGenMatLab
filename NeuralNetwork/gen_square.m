function C = gen_square(radius, x_c, y_c)
%GEN_CIRCLE Generate a square on a 32x32 matrix
x_size = 32;
y_size = 32;

[x, y] = meshgrid(1:x_size, 1:y_size);
C = radius <= abs(x-x_c)+abs(y-y_c) & abs(x-x_c)+abs(y-y_c) <= radius+1;

end

