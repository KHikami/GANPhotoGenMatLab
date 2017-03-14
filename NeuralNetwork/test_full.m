%% Clear the screen and variables
clear;
clc;
close all;

%% Variables for our test script
cost = @(pred, label) -label.*log(pred) - (1-label).*log(1-pred);
cost_grad = @(pred, label) - label./pred + (1-label)./(1-pred);
reg_func = @(w) w.^2;
reg_func_grad = @(w) 2*w;
reg_coeff = 0;%0.01;

feature_dim = [2,1];
first_layer_dim = [3,1];
output_dim = 1;

learning_rate = 0.1;

%% Create a network object and add a layer to it
network = Network(cost, cost_grad, reg_func, reg_func_grad, reg_coeff);
add(network, LinearLayer(feature_dim, first_layer_dim, reg_func, reg_func_grad, reg_coeff));
add(network, ReLULayer());
add(network, LinearLayer(first_layer_dim, output_dim, reg_func, reg_func_grad, reg_coeff ));
add(network, SigmoidLayer());

%% Generate samples in R^2 with two classes (-1,-1) and (1, 1). We add an additive Gausian noise to it.
X = repmat([-1,-1; 1, 1], [50,1]);
X = X + normrnd(0, 0.3, [100,2]);
y = repmat([0;1], [50,1]);
%figure
%plot(X(:,1), X(:,2), 'o');

%% Run gradient descent and check our result
num_ite = 100;
costs = zeros(num_ite,1);
eval_aux = @(w) eval_at(network, X, y, w);
num_params = get_num_params(network);
w_0 = normrnd(0,0.02,[num_params, 1]);
options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', ...
    'SpecifyObjectiveGradient',true, 'Display','iter', 'MaxFunEvals',50);
fminunc(eval_aux, w_0, options);

pred_label = predict(network, X);

%% Test gradient of parameters
epsilon = 10^-10;
for idx = 1:2
[weight, bias] = get_params(network);
[f_old, grad] =  eval_at(network, X, y, weight, bias);
new_weight = weight;
new_weight{1}(idx) = weight{1}(idx) + epsilon;
new_bias = bias;
[f_new, ~] =  eval_at(network, X, y, new_weight, new_bias);
approx_grad = (f_new - f_old)/epsilon;
(grad(idx) - approx_grad) / approx_grad % should be small
end;

%% Test gradient of input
epsilon = 10^-10;
for idx = 1:5
[f_old, ~, grad] =  eval_at(network, X, y, weight, bias);
X_new = X;
X_new(idx) = X(idx) + epsilon;
f_new = eval_at(network, X_new, y, weight, bias);
approx_grad = (f_new-f_old)/epsilon;
(grad(idx) - approx_grad) / approx_grad % Should be small
end;
% %%
% cost = @(pred, label) pred;
% cost_grad = @(pred, label) 1;
% reg = @(w) w.^2;
% reg_grad = @(w) 2*w;
% reg_coeff = 0;
% relu = @(x) x;
% relu_grad = @(x) 1;
% out = @(x) x;
% out_grad = @(x) 1;
% 
% network = Network(1, cost, cost_grad, reg, reg_grad, reg_coeff);
% add_fulllayer(network, 1, 1, relu, relu_grad, 'hidden_layer');
% 
% X = 1;
% y = 1;
% 
% % Test graident
% epsilon = 10^-10;
% [weight, bias] = get_params(network);
% 
% [f_old, ~, grad] =  eval_at(network, X, y, weight, bias);
% X_new = X;
% X_new = X + epsilon;
% f_new = eval_at(network, X, y, weight, bias);
% % (f_new-f_old)/epsilon;
% % grad(1);
