classdef ConvLayer < handle  
  % The convolution layer. Currently pooling is not supported.
  % Also only same size convolution is suported.
  properties (GetAccess=public)
    input_dim;      % Dimension of the input tensor
    kernel_dim;     
    layer_depth;    % Depth of the output tensor
    stride_size;    % A matrix specifying the stride(step) size.
    layer_dim;      % A matrix specifying the dimension of the kernel
    int_kernel_dim; % The dimension of the matrix used to store the kernel 
                    % internally.
    
    input_size;     % Number of entries in the input tensor
    layer_size;     % Number of entries in the output tensor
    
    kernel;         % A prod([kernel_dim, input_depth]) x layer_depth 
                    % matrix representing multiplication by the kernel
    bias;           % An 1 x layer_depth vector to bias pre-activation
    
    grad_kernel;    % Cost's gradient with respect to kernel
    grad_bias;      % Cost's gradient with respect to bias
    
    pre_act_val;    % The computed pre-activation  value
    
    act_func;       % The activation function
    act_func_grad;  % Activation function's gradient
    reg_func;       % The regularization function
    reg_func_grad;  % Regularization function's gradient
    reg_coeff;      % The regularization coefficient
    
    layer_name;     % Name of the layer
  end;
  
  properties (GetAccess=private)
    transpose;
  end;
  
  properties (Constant) 
    init_var = 0.2;
  end;
  
  methods
    function object = ConvLayer(input_dim, kernel_dim, layer_depth, ...
            stride_size, act_func, act_func_grad, reg_func, ...
            reg_func_grad, reg_coeff, layer_name, transpose)
      % Initialize the layer object
      object.input_dim = input_dim;
      object.kernel_dim = kernel_dim;
      object.layer_depth = layer_depth;
      object.stride_size = stride_size;
      
      if ~exist('tranpose', 'var')
        object.transpose = false;
      else
        object.transpose = (transpose == 'transpose');
      end;
      
      if object.transpose
        object.layer_dim = [1+(input_dim(1)-1)*(stride_size(1)+1), ...
          1+(input_dim(2)-1)*(stride_size(2)+1), layer_depth];
      else
        object.layer_dim = [ceil(input_dim(1)/stride_size(1)), ...
          ceil(input_dim(2)/stride_size(2)), layer_depth];
      end;
      
      
      object.int_kernel_dim = [prod([kernel_dim, input_dim(3)]), layer_depth];
      
      object.input_size = prod(input_dim);
      object.layer_size = prod(object.layer_dim);
      
      object.act_func = act_func;
      object.act_func_grad = act_func_grad;
      object.reg_func = reg_func;
      object.reg_func_grad = reg_func_grad;
      object.reg_coeff = reg_coeff;
      object.layer_name = layer_name;
            
      object.kernel = normrnd(0, sqrt(object.init_var), ...
        object.int_kernel_dim);
      object.bias = normrnd(0, sqrt(object.init_var), [1, layer_depth]);
      
      
    end;
  
    function output_val = compute_output(this, input_val)
      % Compute the output of this layer usig the input.
      % Inputs:
      %   input_val: a batch_size x input_dim(1) x input_dim(2) 
      %     x input_depth tensor storing the data.
      % Outputs:  
      %   output_val: the output tensor of dim layer_dim(1) x layer_dim(2)
      %     x layer_depth tensor storing the output
      batch_size = size(input_val, 1);
      this.pre_act_val = zeros([batch_size, this.layer_dim]);
      if ~this.transpose
        for s=1:batch_size
          this.pre_act_val(s,:,:,:) = reshape(...
            im2row(shiftdim(input_val(s,:,:,:),1), this.kernel_dim, this.stride_size)...
            *this.kernel, this.layer_dim) ...
            + this.bias(ones(this.layer_dim(1),1), ones(this.layer_dim(2),1),:);
        end;
      else
        input_val = reshape(input_val, ...
          [batch_size, prod(this.input_dim(1:2)), this.input_dim(3)]);     
        for s = 1:batch_size
          this.pre_act_val(s,:,:,:) = reshape(row2im(shiftdim(input_val(s,:),1) * this.kernel',...
            this.kernel_dim, this.layer_dim, this.stride_size), this.layer_dim)...
            + this.bias(ones(this.layer_dim(1),1), ones(this.layer_dim(2),1),:);
        end;
      end;
      output_val = this.act_func(this.pre_act_val);
    end;
      
    function [prev_layer_grad, grad_kernel, grad_bias] ...
            = compute_grad(this, input_val, layer_grad)
      % Assume that fprop had already been run. 
      % Computes regularized cost's gradient with respect to the input, the
      % kernel, and the bias at input_val. It uses layer_grad to
      % to back propagate.
      % Inputs:
      %   input: a batch_size x input_dim(1) x input_dim(2) x layer_depth
      %     tensor storingthe input.
      %   layer_grad: a batch_size x layer_dim matrix representing the 
      %     cost function's gradient with respect to the output of this 
      %     layer.
      % Outputs:  
      %   kernel_grad: a batch_size x int_kernel_dim matrix 
      %     representing the cost function's gradient with respect to the 
      %     kernel at each input value.
      %   bias_grad: a batch_size x 1 x layer_depth tensor 
      %     representing the cost function's gradient with respect to the 
      %     bias at each input value.
      %   prev_layer_grad: a batch_size x input_dim matrix representing 
      %     the cost function's gradient with respect to the input.
      batch_size = size(input_val, 1);
      grad_pre_act = layer_grad .* this.act_func_grad(this.pre_act_val);
      grad_bias = sum(sum(grad_pre_act, 2),3);
      
      prev_layer_grad = zeros([batch_size, this.input_dim]);
      grad_kernel = zeros([batch_size, this.int_kernel_dim]);
      
      if ~this.transpose
        grad_pre_act = reshape(grad_pre_act, ...
        [batch_size, prod(this.layer_dim(1:2)), this.layer_depth]);
        for s = 1:batch_size
          aux_input = im2row(shiftdim(input_val(s,:,:,:),1), this.kernel_dim, this.stride_size);
          grad_kernel(s,:,:) =aux_input' * shiftdim(grad_pre_act(s,:,:),1) ...
              + this.reg_coeff * this.reg_func_grad(this.kernel); 

          prev_layer_grad(s,:,:,:) = reshape(row2im(shiftdim(grad_pre_act(s,:),1) * this.kernel',...
              this.kernel_dim, this.input_dim, this.stride_size), this.input_dim);
        end;
      else
        for s=1:batch_size
          prev_layer_grad(s,:,:,:) = reshape(...
            im2row(shiftdim(grad_pre_act(s,:,:,:),1), this.kernel_dim, this.stride_size)...
            *this.kernel, this.input_dim);
        end;
      end;
    end;
    
    function [back_grad, grad_kernel, grad_bias] ...
            = update_grad(this, input_val, layer_grad)
      % This function will update the stochastic gradient variables stored 
      % in NetworkLayer
      %   kernel_grad: an int_ker_dim tensor representing the 
      %     cost function's stochastic gradient with respect to the kernel.
      %   bias_grad: a 1 x layer_depth tensor representing the cost
      %     function's gradient with respect to the bias.
      %   back_grad_grad: a input_dim matrix representing 
      %     the cost function's gradient with respect to the input.
      [back_grad, grad_kernel, grad_bias] ...
          = compute_grad(this, input_val, layer_grad);
      grad_kernel = mean(grad_kernel, 1);
      grad_bias = mean(grad_bias, 1);
      
      temp = size(grad_kernel);
      if ndims(grad_kernel) > 1
        grad_kernel = reshape(grad_kernel, [temp(2:end), 1]);
      end;

      this.grad_kernel = grad_kernel;
      this.grad_bias = grad_bias;
    end;
    
    function [kernel, bias] = get_params(this)
        % Return the weight and bias of this layer
        kernel = this.kernel;
        bias = this.bias;
    end;
    
    function set_params(this, kernel, bias)
        % Set the weight and bias
        this.kernel = kernel;
        this.bias = bias;
    end;
    
    function [grad_kernel, grad_bias] = get_grad(this)
        % Get the gradients w.r.t. to the parameters
        grad_kernel = this.grad_kernel;
        grad_bias = this.grad_bias;
    end;
    
    function [int_kernel_dim, bias_dim] = get_params_dim(this)
        int_kernel_dim = size(this.kernel);
        bias_dim = size(this.bias);
    end;
    
    function descent(this, learning_rate)
      % Change the weights and biases by -learning_rate*grad
      % Inputs:
      %   leaning_rate: the step_size of the descent
      this.kernel = this.kernel - learning_rate * this.grad_kernel;
      this.bias = this.bias - learning_rate * this.grad_bias;
    end;
  end;
end