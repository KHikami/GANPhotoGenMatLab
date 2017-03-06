%% Clear the screen and variables
clear;
clc;
close all;

%% Variables for our test script
cost = @(pred, label) -mean(label.*log(pred) + (1-label).*log(1-pred));
cost_grad = @(pred, label) - label./pred + (1-label)./(1-pred);
reg = @(w) w.^2;
reg_grad = @(w) 2*w;
reg_coeff = 0.01;
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
learning_rate = 1;

%% Create a network object and add a layer to it
network = Network(im_dim, cost, cost_grad, reg, reg_grad, reg_coeff);
add_convlayer(network, im_dim, kernel_dim, convlayer_depth, ...
        stride_size, relu, relu_grad, 'conv_layer');
convlayer_dim = network.network_layers{1}.layer_dim;
add_layer(network, convlayer_dim, 1, out, out_grad, 'output_full');

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
for i=1:num_ite
    costs(i) = grad_descent(network, X, y, learning_rate);
    plot(costs); drawnow;
end;

pred_label = predict(network, X);












