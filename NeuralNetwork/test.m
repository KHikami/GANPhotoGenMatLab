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
feature_size = 2;
layer_size = 1;
learning_rate = 0.1;

%% Create a network object and add a layer to it
network = Network(feature_size, cost, cost_grad, reg, reg_grad, reg_coeff);
add_layer(network, [1,feature_size], [1,3], relu, relu_grad, 'hidden_layer_1');
add_layer(network, [1,3], 1, out, out_grad, 'output_layer_1');

%% Generate samples in R^2 with two classes (-1,-1) and (1, 1). We add an additive Gausian noise to it.
X = repmat([-1,-1; 1, 1], [50,1]);
X = X + normrnd(0, 0.3, [100,2]);
y = repmat([0;1], [50,1]);
%figure
%plot(X(:,1), X(:,2), 'o');

%% Run gradient descent and check our result
costs = zeros(1000,1);
for i=1:1000
    grad_descent(network, X, y, learning_rate)
    costs(i) = network.current_cost;
end;
figure
plot(costs);
%network.layers_output{2}
%%
% bprop(network, X, y);
% [weight_grad, bias_grad] = get_grad(network);
% weight_grad = weight_grad{1};
% bias_grad = bias_grad{1};
% grad = [weight_grad; bias_grad]

%%
% [weight, bias] = get_params(network);
% weight = weight{1};
% bias = bias{1};
% param = [weight; bias];
% f = @(params) eval_at_param(network, params, X, y);
% epsilon = 10^-10;
% D_1 = [f(param + epsilon * [1;0;0]) - f(param - epsilon * [1;0;0])]/epsilon/2
% D_2 = [f(param + epsilon * [0;1;0]) - f(param - epsilon * [0;1;0])]/epsilon/2
% D_3 = [f(param + epsilon * [0;0;1]) - f(param - epsilon * [0;0;1])]/epsilon/2
