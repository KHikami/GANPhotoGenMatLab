function C = gen_circle(radius, x_c, y_c)
%GEN_CIRCLE Generate a circle on a 32x32 matrix
x_size = 32;
y_size = 32;

[x, y] = meshgrid(1:x_size, 1:y_size);
C = radius <= sqrt((x-x_c).^2+(y-y_c).^2) & sqrt((x-x_c).^2+(y-y_c).^2) <= radius+1;

end

