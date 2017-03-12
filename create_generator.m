function generator = create_generator(D, D_grad)
%CREATE_GENERATOR Create a generator for DCGAN training.
%   INPUTS:
%       D: A function handle that takes in an 64 x 64 image and return the
%       discriminator's belief that the image is not a generated one
%       D_grad: A function handle that returns the gradient of the
%       discriminator's output with respect to the input 64 x 64 image

%% Set the parameters
% The functions that we need
cost = @(output) log(1-D(output));
cost_grad = @(output) -D_grad(output)/(1-D(output));

reg = @(w) w.^2;
reg_grad = @(w) 2*w; 
reg_coeff = 10^-6;

relu = @(x) max(x, 0);
relu_grad = @(x) max(sign(x),0);

output_act = @(x) tanh(x);
output_act_grad = @(x) sech(x).^2;

% The dimensions of the layers
kernel_dim = [5,5];
stride_size = [2,2];
seed_dim = [100,1];
reshape_layer_dim = [4,4,1024];
transconv_layer_1_dim = [8,8,512];
transconv_layer_2_dim = [16,16,256];
transconv_layer_3_dim = [32,32,128];
image_dim = [64, 64, 3];

%% Create the generator
generator = Network(seed_dim, cost, cost_grad, reg, reg_grad, reg_coeff);
add_fulllayer(generator, seed_dim, reshape_layer_dim, relu, relu_grad, ...
    'reshape_layer');
add_transconvlayer(generator, reshape_layer_dim, kernel_dim, ...
    reshape_layer_dim(3)/2, stride_size, relu, relu_grad, 'transconv_1');
add_transconvlayer(generator, transconv_layer_1_dim, kernel_dim, ...
    reshape_layer_dim(3)/2^2, stride_size, relu, relu_grad, 'transconv_2');
add_transconvlayer(generator, transconv_layer_2_dim, kernel_dim, ...
    reshape_layer_dim(3)/2^3, stride_size, relu, relu_grad, 'transconv_3');
add_transconvlayer(generator,  transconv_layer_3_dim, kernel_dim, image_dim(3), ...
    stride_size, output_act, output_act_grad, 'output_layer');

end;