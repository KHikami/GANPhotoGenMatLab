function discriminator = create_discriminator()
%CREATE_DISCRIMINATOR Create a discriminator for DCGAN training.

%% Set the parameters
% The functions that we need
cost = @(generated_score, real_score) log(real_score);% + log(1-generated_score);
cost_grad = @(generated_score, real_score) 1/real_score;% - 1/(1-generated_score);

reg_func = @(w) w.^2;
reg_func_grad = @(w) 2*w; 
reg_coeff = 0;%10^-6;

leaky_coeff = 0.2;
p = 0.2;

% The dimensions of the layers
kernel_dim = [5,5];
stride_size = [2,2];
image_dim = [32, 32, 1];
conv_layer_1_dim = [16,16,32];
conv_layer_2_dim = [8,8,64];
conv_layer_3_dim = [4,4,96];
conv_layer_4_dim = [2,2,128];

%% Create the discirminator
discriminator = Network(cost, cost_grad, reg_func, reg_func_grad, reg_coeff);

add(discriminator, ConvLayer(image_dim, kernel_dim, conv_layer_1_dim(3), ...
    stride_size, reg_func, reg_func_grad, reg_coeff));
%add(discriminator, ConvBatchNormLayer(conv_layer_1_dim));
add(discriminator, ReLULayer(leaky_coeff));

add(discriminator, DropOutLayer(conv_layer_1_dim, p));
add(discriminator, ConvLayer(conv_layer_1_dim, kernel_dim, conv_layer_2_dim(3), ...
    stride_size, reg_func, reg_func_grad, reg_coeff));
%add(discriminator, ConvBatchNormLayer(conv_layer_2_dim));
add(discriminator, ReLULayer(leaky_coeff));

add(discriminator, DropOutLayer(conv_layer_2_dim, p));
add(discriminator, ConvLayer(conv_layer_2_dim, kernel_dim, conv_layer_3_dim(3), ...
    stride_size, reg_func, reg_func_grad, reg_coeff));
%add(discriminator, ConvBatchNormLayer(conv_layer_3_dim));
add(discriminator, ReLULayer(leaky_coeff));

add(discriminator, DropOutLayer(conv_layer_3_dim, p));
add(discriminator, ConvLayer(conv_layer_3_dim, kernel_dim, conv_layer_4_dim(3), ...
    stride_size, reg_func, reg_func_grad, reg_coeff));
%add(discriminator, ConvBatchNormLayer(conv_layer_4_dim));
add(discriminator, ReLULayer(leaky_coeff));

add(discriminator, DropOutLayer(conv_layer_4_dim, p));
add(discriminator, LinearLayer(conv_layer_4_dim, 1, reg_func, reg_func_grad, reg_coeff));
add(discriminator, SigmoidLayer());
end

