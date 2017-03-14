function generator = create_generator()
%CREATE_GENERATOR Create a generator for DCGAN training.

%% Set the parameters
% The functions that we need
cost = @(output) 1;%log(1-D(output));
cost_grad = @(output) output;%-D_grad(output)/(1-D(output));

reg = @(w) w.^2;
reg_grad = @(w) 2*w; 
reg_coeff = 0;%10^-6;

% The dimensions of the layers
kernel_dim = [5,5];
stride_size = [2,2];
seed_dim = [50,1];
reshape_dim = [2,2,256];
transconv_layer_1_dim = [4,4,128];
transconv_layer_2_dim = [8,8,64];
transconv_layer_3_dim = [16,16,32];
image_dim = [32, 32, 1];

%% Create the generator
generator = Network(cost, cost_grad, reg, reg_grad, reg_coeff);

add(generator, LinearLayer(seed_dim, reshape_dim, reg, reg_grad, reg_coeff));
add(generator, ReLULayer());

add(generator, TransConvLayer(reshape_dim, kernel_dim, ...
    transconv_layer_1_dim(3), stride_size, reg, reg_grad, reg_coeff));
add(generator, ConvBatchNormLayer(transconv_layer_1_dim));
add(generator, ReLULayer());

add(generator, TransConvLayer(transconv_layer_1_dim, kernel_dim, ...
    transconv_layer_2_dim(3), stride_size, reg, reg_grad, reg_coeff));
add(generator, ConvBatchNormLayer(transconv_layer_2_dim));
add(generator, ReLULayer());

add(generator, TransConvLayer(transconv_layer_2_dim, kernel_dim, ...
    transconv_layer_3_dim(3), stride_size, reg, reg_grad, reg_coeff));
add(generator, ConvBatchNormLayer(transconv_layer_3_dim));
add(generator, ReLULayer());

add(generator, TransConvLayer(transconv_layer_3_dim, kernel_dim, ...
    image_dim(3), stride_size, reg, reg_grad, reg_coeff));
add(generator, ConvBatchNormLayer(image_dim));
add(generator, TanhLayer());

end