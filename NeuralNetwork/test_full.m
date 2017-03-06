%% Clear the screen and variables
clear;
clc;
close all;

%% Variables for our test script
epsilon = 10^-3;
cost = @(pred, label) -mean(label.*log(pred) + (1-label).*log(1-pred));
cost_grad = @(pred, label) - label./pred + (1-label)./(1-pred);
reg = @(w) w.^2;
reg_grad = @(w) 2*w;
reg_coeff = 0.01;
relu = @(x) max(x, 0);
relu_grad = @(x) max(sign(x),0);
out = @(x) 1./(1+exp(-x));
out_grad = @(x) out(x).*(1-out(x));

feature_dim = [2,1];
hidden_layer_dim = [3,1];
output_dim = 1;

learning_rate = 0.1;

%% Create a network object and add a layer to it
network = Network(feature_dim, cost, cost_grad, reg, reg_grad, reg_coeff);
add_layer(network, feature_dim, hidden_layer_dim, relu, relu_grad, 'hidden_layer');
add_layer(network, hidden_layer_dim, output_dim, out, out_grad, 'output_layer_1');

%% Generate samples in R^2 with two classes (-1,-1) and (1, 1). We add an additive Gausian noise to it.
X = repmat([-1,-1; 1, 1], [50,1]);
X = X + normrnd(0, 0.3, [100,2]);
y = repmat([0;1], [50,1]);
%figure
%plot(X(:,1), X(:,2), 'o');

%% Run gradient descent and check our result
num_ite = 1000;
costs = zeros(num_ite,1);
for i=1:num_ite
   costs(i) = grad_descent(network, X, y, learning_rate);
    plot(costs); drawnow;
end;

pred_label = predict(network, X);
