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

im_length = 32;
im_dim = [im_length, im_length, 1];
kernel_dim = [5,5];
stride_size = [1,1];
convlayer_depth = 1;
layer_size = 1;
learning_rate = 0.1;

%% Create a network object and add a layer to it
network = Network(im_dim, cost, cost_grad, reg, reg_grad, reg_coeff);
add_convlayer(network, im_dim, kernel_dim, convlayer_depth, ...
        stride_size, relu, relu_grad, 'conv_layer');
add_layer(network, im_dim, 1, out, out_grad, 'output_full');

%% Generate a bunch of 32x32 images of circles and squares. Circles are 1's
% and squares are 0's

num_circles = 100;
num_squares = 100;
X = zeros([num_circles+num_squares, im_dim]);
y = zeros(num_circles+num_squares,1);
y(1:num_circles) = 1;

for i=1:num_circles
    X(i,:,:) = gen_circle(randi([5,10]), randi([11,22]), randi([11,22]));
end;

for j=num_circles+1:num_squares+num_circles
    X(j,:,:) = gen_square(randi([5,10]), randi([11,22]), randi([11,22]));
end;

%% Run gradient descent and check our result
costs = zeros(1000,1);
for i=1:1000
    i
    grad_descent(network, X, y, learning_rate)
    costs(i) = network.current_cost;
end;
figure
plot(costs);











