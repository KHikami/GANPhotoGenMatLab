%% Clear the screen and variables
clear;
clc;
close all;

%% Variables for our test script
epsilon = 10^-10;
cost = @(pred, label) -label.*log(pred+epsilon) - (1-label).*log(1-pred+epsilon);
cost_grad = @(pred, label) - label./(pred+epsilon) + (1-label)./(1-pred+epsilon);
reg_func = @(w) w.^2;
reg_func_grad = @(w) 2*w;
reg_coeff = 0;

im_length = 32;
im_dim = [im_length, im_length, 1];
kernel_dim = [5,5];
stride_size = [2,2];
convlayer_1_depth = 2;
convlayer_2_depth = 4;
output_dim = 1;
learning_rate = 0.5;

%% Create a network object and add a layer to it
network = Network(cost, cost_grad, reg_func, reg_func_grad, reg_coeff);
add(network, ConvBatchNormLayer(im_dim));
add(network, LinearLayer(im_dim, output_dim, reg_func, reg_func_grad, reg_coeff));
add(network, SigmoidLayer());

%% Generate a bunch of 32x32 images of circles and squares. Circles are 1's
% and squares are 0's
num_circles = 10;
num_squares = 10;
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
options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', ...
    'SpecifyObjectiveGradient',true, 'Display','iter', 'MaxIter',50);
[x, f] = fminunc(eval_aux, x_0, options);

pred_label = predict(network, X);

%% Check the gradient wrt parameters by performing numerical differentiation
epsilon = 10^-10;
[weight, bias] = get_params(network);
for idx=1:1
    [f_old, grad] =  eval_at(network, X, y, weight, bias);
    new_weight = weight;
 %   new_weight{1}(idx) = weight{1}(idx) + epsilon;
    new_bias = bias;
    new_bias{1}(idx) = bias{1}(idx) + epsilon;
    [f_new, ~] =  eval_at(network, X, y, new_weight, new_bias);
    approx_grad = (f_new - f_old)/epsilon;
    %(grad(idx)-approx_grad)/approx_grad
    (grad(idx+1)-approx_grad)/approx_grad
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
