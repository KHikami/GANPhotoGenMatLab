%% Clear the screen and variables
clear;
clc;
close all;

%% Variables for our test script
cost = @(pred, label) -mean(label.*log(pred) + (1-label).*log(1-pred));
cost_grad = @(pred, label) - label./pred + (1-label)./(1-pred);
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
add_convlayer(network, convlayer_dim, kernel_dim, convlayer_depth, ...
        stride_size, relu, relu_grad, 'conv_layer_2');
convlayer_dim = network.network_layers{2}.layer_dim;
add_fulllayer(network, convlayer_dim, 1, out, out_grad, 'output_full');

%% Generate a bunch of 32x32 images of circles and squares. Circles are 1's
% and squares are 0's

num_circles = 100;
num_squares = 100;
X = zeros([num_circles+num_squares, im_dim]);
y = zeros(num_circles+num_squares,1);
y(1:num_circles) = 1;

for i=1:num_circles
    X(i,:,:) = gen_circle(randi([5,10]), randi([11,22]), randi([11,22]), im_length);
end;

for j=num_circles+1:num_squares+num_circles
    X(j,:,:) = gen_square(randi([5,10]), randi([11,22]), randi([11,22]), im_length);
end;

%% Run gradient descent and check our result
num_ite = 100;
costs = zeros(num_ite,1);
eval_aux = @(w) eval_at(network, X, y, w);
num_params = get_num_params(network);
x_0 = normrnd(0,0.2,[num_params, 1]);
options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'SpecifyObjectiveGradient',true, 'Display','iter', 'MaxFunEvals',100);
fminunc(eval_aux, x_0, options);

pred_label = predict(network, X);

%% Check the gradient by performing numerical differentiation
% epsilon = 10^-8;
% 
% for idx=1:25
% [~, J] = fprop(network, X, y);
% bprop(network, X, y);
% [algo_grad_weight, algo_grad_bias] = get_grad(network);
% 
% [weight, bias] = get_params(network);
% new_weight = weight;
% new_bias = bias;
% new_weight{1}(idx) = new_weight{1}(idx)+epsilon;
% %new_bias{1}(1) = new_bias{1}(1)+epsilon;
% set_params(network, new_weight, new_bias);
% [~, J_new] = fprop(network, X, y);
% grad_aprox = (J_new - J)/epsilon;
% 
% 
% %algo_grad_bias{1}(1)
% difference = algo_grad_weight{1}(idx) - grad_aprox
%end;



