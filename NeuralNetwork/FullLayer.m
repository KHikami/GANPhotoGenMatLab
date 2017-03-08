classdef FullLayer < handle  
  properties (GetAccess=public)
    input_dim;      % Dimension of the input tensor
    layer_dim;      % Dimension of the output tensor
    input_size;     % Number of entries in the input tensor
    layer_size;     % Number of entries in the output tensor
    
    weight;         % An input_size x layer_size matrix to compute pre-act.
    bias;           % An 1 x layer_size vector to bias pre-activation
    
    grad_weight;    % Cost's gradient with respect to weight
    grad_bias;      % Cost's gradient with respect to bias
    
    pre_act_val;    % The computed pre-activation  value
    
    act_func;       % The activation function
    act_func_grad;  % Activation function's gradient
    reg_func;       % The regularization function
    reg_func_grad;  % Regularization function's grdient
    reg_coeff;      % The regularization coefficient
    
    layer_name;     % Name of the layer
  end;
  
  properties (Constant) 
    init_var = 0.2;
  end;
  
  methods
    function object = FullLayer(input_dim, layer_dim, ...
            act_func, act_func_grad, reg_func, reg_func_grad, ...
            reg_coeff, layer_name)
      % Initialize the layer object
      object.input_dim = input_dim;
      object.input_size = prod(input_dim);
      object.layer_dim = layer_dim;
      object.layer_size = prod(layer_dim);
      object.act_func = act_func;
      object.act_func_grad = act_func_grad;
      object.reg_func = reg_func;
      object.reg_func_grad = reg_func_grad;
      object.reg_coeff = reg_coeff;
      object.layer_name = layer_name;
            
      object.weight = normrnd(0, sqrt(object.init_var), ...
          [object.input_size, object.layer_size]);
      object.bias = normrnd(0, sqrt(object.init_var), [1, object.layer_size]);
    end;
  
    function output_val = compute_output(this, input_val)
      % Compute the output of this layer usig the input.
      % Inputs:
      %   input_val: a batch_size x input_dim_1 x input_dim_2 x input_dim_3
      %     tensor storingthe input.
      % Outputs:  
      %   output_val: the output values from this layer
      batch_size = size(input_val, 1);
      this.pre_act_val = ...
          reshape(input_val, [batch_size, this.input_size])* ...
          this.weight + this.bias(ones(batch_size,1), :);
      output_val = reshape(this.act_func(this.pre_act_val), ...
          [batch_size, this.layer_dim]);
    end;
      
    function [prev_layer_grad, grad_weight, grad_bias] ...
            = compute_grad(this, input_val, layer_grad)
      % Computes regularized cost's gradient with respect to the input, the
      % layer weight, and the layer bias at input. It uses layer_grad to
      % to back propagate.
      % Inputs:
      %   input: a batch_size x input_dim_1 x input_dim_2 x input_dim_3
      %     tensor storingthe input.
      %   layer_grad: a batch_size x layer_size matrix representing the 
      %     cost function's gradient with respect to the output of this 
      %     layer.
      % Outputs:  
      %   weight_grad: a batch_size x input_size x layer_size tensor 
      %     representing the cost function's gradient with respect to the 
      %     weight at each input value.
      %   bias_grad: a batch_size x input_size x layer_size tensor 
      %     representing the cost function's gradient with respect to the 
      %     bias at each input value.
      %   prev_layer_grad: a batch_size x input_size matrix representing 
      %     the cost function's gradient with respect to the input.
      batch_size = size(input_val, 1);
      input_val = reshape(input_val, [batch_size, this.input_size]);
      
      grad_pre_act = layer_grad .* this.act_func_grad(this.pre_act_val);
      grad_bias = grad_pre_act;
      
      prev_layer_grad = zeros(batch_size, this.input_size);
      grad_weight = zeros(batch_size, this.input_size, this.layer_size);
      for s = 1:batch_size
        grad_weight(s,:,:) = input_val(s,:)' ...
            * grad_pre_act(s,:) + this.reg_coeff ...
            * this.reg_func_grad(this.weight); 
        prev_layer_grad(s,:) = grad_pre_act(s,:) * this.weight';
      end;
      prev_layer_grad = reshape(prev_layer_grad, [batch_size, this.input_dim]);
    end;
    
    function [back_grad, grad_weight, grad_bias] ...
            = update_grad(this, input_val, layer_grad)
      % This function will update the stochastic gradient variables stored 
      % in NetworkLayer
      %   weight_grad: a input_size x layer_size tensor representing the 
      %     cost function's stochastic gradient.
      %   bias_grad: a input_size x layer_size tensor representing the cost 
      %     function's stochastic gradient with respect to the bias.
      %   back_grad_grad: a input_size matrix representing the cost
      %     function's stochastic gradient with respect to the input.
      [back_grad, grad_weight, grad_bias] ...
          = compute_grad(this, input_val, layer_grad);
      grad_weight = mean(grad_weight, 1);
      grad_bias = mean(grad_bias, 1);
      
      grad_weight = shiftdim(grad_weight, 1);

      this.grad_weight = grad_weight;
      this.grad_bias = grad_bias;
    end;
    
    function [weight, bias] = get_params(this)
        % Return the weight and bias of this layer
        weight = this.weight;
        bias = this.bias;
    end;
    
    function set_params(this, weight, bias)
        % Set the weight and bias
        this.weight = weight;
        this.bias = bias;
    end;
    
    function [grad_weight, grad_bias] = get_grad(this)
        % Get the gradients w.r.t. to the parameters
        grad_weight = this.grad_weight;
        grad_bias = this.grad_bias;
    end;
    
    function [weight_dim, bias_dim] = get_params_dim(this)
        weight_dim = size(this.weight);
        bias_dim = size(this.bias);
    end;
    
    function descent(this, learning_rate)
      % Change the weights and biases by -learning_rate*grad
      % Inputs:
      %   leaning_rate: the step_size of the descent
      this.weight = this.weight - learning_rate * this.grad_weight;
      this.bias = this.bias - learning_rate * this.grad_bias;
    end;
  end;
end