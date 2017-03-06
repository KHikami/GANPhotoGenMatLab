function C = gen_circle(radius, x_c, y_c, im_size)
%GEN_CIRCLE Generate a circle 

[x, y] = meshgrid(1:im_size, 1:im_size);
C = radius <= sqrt((x-x_c).^2+(y-y_c).^2) & sqrt((x-x_c).^2+(y-y_c).^2) <= radius+1;

end

