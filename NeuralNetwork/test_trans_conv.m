%% Clear the screen and variables
clear;
clc;
close all;

%% Variables for our test script
cost = @(pred, label) norm(pred - label,'fro')^2;
cost_grad = @(pred, label) 2*(pred-label);
reg_func = @(w) w.^2;
reg_func_grad = @(w) 2*w;
reg_coeff = 0;%0.001;
relu = @(x) max(x, 0);
relu_grad = @(x) max(sign(x),0);
out = @(x) 1./(1+exp(-x));
out_grad = @(x) out(x).*(1-out(x));

im_length = 32;
im_dim = [im_length, im_length, 1];
kernel_dim = [5,5];
stride_size = [2,2];
convlayer_depth = 1;
layer_size = 1;
learning_rate = 0.5;

%% Create a network object and add a layer to it
network = Network(cost, cost_grad, reg_func, reg_func_grad, reg_coeff);
add(network, ConvLayer(im_dim, kernel_dim, convlayer_depth, ...
    stride_size, reg_func, reg_func_grad, reg_coeff));
add(network, ReLULayer());
convlayer_dim = network.network_layers{1}.layer_dim;
add(network, TransConvLayer(convlayer_dim, kernel_dim, convlayer_depth, ...
        stride_size, reg_func, reg_func_grad, reg_coeff));
add(network, ReLULayer());

%% Generate a bunch of 32x32 images of squares.

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

pred_label = predict(network, X);

%% Check the gradient wrt parameters by performing numerical differentiation
epsilon = 10^-10;
for idx=1:5
    [weight, bias] = get_params(network);
    [f_old, grad] =  eval_at(network, X, y, weight, bias);
    new_weight = weight;
    new_weight{1}(idx) = weight{1}(idx) + epsilon;
    new_bias = bias;
    [f_new, ~] =  eval_at(network, X, y, new_weight, new_bias);
    approx_grad = (f_new - f_old)/epsilon;
    (grad(idx)-approx_grad)/approx_grad
end;

%% Check the gradient wrt input by performing numerical differentiation
epsilon = 10^-10;
for idx=1:5
    [f_old, ~, grad] =  eval_at(network, X, y, weight, bias);
    X_new = X;
    X_new(idx) = X(idx) + epsilon;
    f_new = eval_at(network, X_new, y, weight, bias);
    approx_grad = (f_new-f_old)/epsilon;
    (grad(idx)-approx_grad)/approx_grad
end;
