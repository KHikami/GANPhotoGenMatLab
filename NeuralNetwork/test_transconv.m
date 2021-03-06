%% Clear the screen and variables
clear;
clc;
close all;

%% Variables for our test script
cost = @(pred, label) norm(pred - label,'fro')^2;
cost_grad = @(pred, label) 2*(pred-label);
reg = @(w) w.^2;
reg_grad = @(w) 2*w;
reg_coeff = 0.001;
relu = @(x) max(x, 0);
relu_grad = @(x) max(sign(x),0);
out = @(x) 1./(1+exp(-x));
out_grad = @(x) out(x).*(1-out(x));

im_length = 33;
im_dim = [im_length, im_length, 1];
kernel_dim = [5,5];
stride_size = [2,2];
convlayer_depth = 1;
layer_size = 1;
learning_rate = 0.5;

%% Create a network object and add a layer to it
network = Network(im_dim, cost, cost_grad, reg, reg_grad, reg_coeff);
add_convlayer(network, im_dim, kernel_dim, convlayer_depth, ...
        stride_size, relu, relu_grad, 'conv_layer');
convlayer_dim = network.network_layers{1}.layer_dim;
add_transconvlayer(network, convlayer_dim, kernel_dim, convlayer_depth, ...
        stride_size, relu, relu_grad, 'transconv_layer');
%convlayer_dim = network.network_layers{2}.layer_dim;
%add_fulllayer(network, convlayer_dim, 1, out, out_grad, 'output_full');

%% Generate a bunch of 33x33 images of squares.

num_circles = 100;
X = zeros([num_circles, im_dim]);

for i=1:num_circles
    X(i,:,:) = gen_circle(randi([5,10]), randi([11,22]), randi([11,22]), im_length);
end;
y=X;

%% Run gradient descent and check our result
num_ite = 100;
eval_aux = @(w) eval_at(network, X, y, w);
num_params = get_num_params(network);
x_0 = normrnd(0,0.2,[num_params, 1]);
options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', ...
    'SpecifyObjectiveGradient',true, 'Display','iter', 'MaxFunEvals',50);
fminunc(eval_aux, x_0, options);

% pred_label = predict(network, X);
% 
% %% Check the gradient by performing numerical differentiation
epsilon = 10^-10;
for layer = 1:2;
for idx=1:10
[~, J] = fprop(network, X, y);
bprop(network, X, y);
[algo_grad_weight, algo_grad_bias] = get_grad(network);

[weight, bias] = get_params(network);
new_weight = weight;
new_bias = bias;
new_weight{layer}(idx) = new_weight{layer}(idx)+epsilon;
%new_bias{layer}(idx) = new_bias{layer}(idx)+epsilon;
set_params(network, new_weight, new_bias);
[~, J_new] = fprop(network, X, y);
grad_aprox = (J_new - J)/epsilon;

difference = algo_grad_weight{layer}(idx) - grad_aprox
%difference = algo_grad_bias{layer}(idx) - grad_aprox
end;
end;
