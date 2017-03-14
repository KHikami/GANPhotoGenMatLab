classdef LinearLayer < handle  
  properties (GetAccess=public)
    input_dim;      % Dimension of the input tensor
    layer_dim;      % Dimension of the output tensor
    input_size;     % Number of entries in the input tensor
    layer_size;     % Number of entries in the output tensor
    
    weight;         % An input_size x layer_size matrix to compute pre-act
    bias;           % An 1 x layer_size vector to bias pre-activation
    
    reg_func;       % The regularization function
    reg_func_grad;  % Regularization function's grdient
    reg_coeff;      % The regularization coefficient
    
  end;
  
  properties (Constant) 
    init_var = 0.02;
  end;
  
  methods
    function object = LinearLayer(input_dim, layer_dim, ...
            reg_func, reg_func_grad, reg_coeff)
      % Initialize the layer object
      object.input_dim = input_dim;
      object.input_size = prod(input_dim);
      object.layer_dim = layer_dim;
      object.layer_size = prod(layer_dim);
      object.reg_func = reg_func;
      object.reg_func_grad = reg_func_grad;
      object.reg_coeff = reg_coeff;
            
      object.weight = normrnd(0, sqrt(object.init_var), ...
          [object.input_size, object.layer_size]);
      object.bias = normrnd(0, sqrt(object.init_var), [object.layer_size,1]);
    end;
  
    function [output_val] = compute_output(this, input_val)
      % Compute the output of this layer usig the input.
      % Inputs:
      %   input_val: a batch_size x input_dim_1 x input_dim_2 x input_dim_3
      %     tensor storingthe input.
      % Outputs:  
      %   output_val: the output values from this layer
      batch_size = size(input_val, 1);
      output_val = bsxfun(@plus, ...
          reshape(input_val, [batch_size, this.input_size])*this.weight,...
          shiftdim(this.bias, -1));
      output_val = reshape(output_val, ...
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
      %   weight_grad: a input_size x layer_size tensor representing the 
      %     cost function's stochastic gradient with respect to the weight.
      %   bias_grad: a layer_size x 1 tensor representing the cost
      %     function's stochastic gradient with respect to the bias.
      %   prev_layer_grad: a batch_size x input_size matrix representing 
      %     the cost function's gradient with respect to the input.
      batch_size = size(input_val, 1);
      input_val = reshape(input_val, [batch_size, this.input_size]);
      layer_grad = reshape(layer_grad, [batch_size, this.layer_size]);
      
      %Get the gradient with respect to each individual entry
      grad_bias = layer_grad;
      
      prev_layer_grad = zeros(batch_size, this.input_size);
      grad_weight = zeros(batch_size, this.input_size, this.layer_size);
      for s = 1:batch_size
        grad_weight(s,:,:) = input_val(s,:)'* layer_grad(s,:) ...
            + this.reg_coeff * this.reg_func_grad(this.weight); 
        prev_layer_grad(s,:) = layer_grad(s,:) * this.weight';
      end;
      
      % Average them to get the stochastic gradient
      grad_weight = shiftdim(sum(grad_weight, 1),1);
      grad_bias = shiftdim(sum(grad_bias, 1),1);  
      
      % Also get the gradient with respect to the input of the layer
      prev_layer_grad = reshape(prev_layer_grad, [batch_size, this.input_dim]);
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

    function [weight_dim, bias_dim] = get_params_dim(this)
        weight_dim = size(this.weight);
        bias_dim = size(this.bias);
    end;
    
  end;
end