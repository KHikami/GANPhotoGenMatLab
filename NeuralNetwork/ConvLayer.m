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
    
    reg_func;       % The regularization function
    reg_func_grad;  % Regularization function's gradient
    reg_coeff;      % The regularization coefficient

  end;
  
  properties (GetAccess=private)
    
  end;
  
  properties (Constant) 
    init_var = 0.2;
  end;
  
  methods
    function object = ConvLayer(input_dim, kernel_dim, layer_depth, ...
            stride_size, reg_func, reg_func_grad, reg_coeff)
      % Initialize the layer object
      object.input_dim = input_dim;
      object.kernel_dim = kernel_dim;
      object.layer_depth = layer_depth;
      object.stride_size = stride_size;
      
      object.layer_dim = [ceil(input_dim(1)/stride_size(1)), ...
          ceil(input_dim(2)/stride_size(2)), layer_depth];
      object.int_kernel_dim = [prod([kernel_dim, input_dim(3)]), layer_depth];
    
      object.input_size = prod(input_dim);
      object.layer_size = prod(object.layer_dim);
      
      object.reg_func = reg_func;
      object.reg_func_grad = reg_func_grad;
      object.reg_coeff = reg_coeff;
            
      object.kernel = normrnd(0, sqrt(object.init_var), ...
        object.int_kernel_dim);
      object.bias = normrnd(0, sqrt(object.init_var), [layer_depth, 1]);
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
        output_val = zeros([batch_size, this.layer_dim]);
        for s=1:batch_size
            output_val(s,:,:,:) = bsxfun(@plus, reshape(...
                im2row(shiftdim(input_val(s,:,:,:),1), this.kernel_dim, this.stride_size)...
                *this.kernel, this.layer_dim), ...
                shiftdim(this.bias,-2));
        end;
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
        grad_bias = sum(sum(layer_grad, 2),3);
       
        % Calculate the gradient with respect to each batch entry
        prev_layer_grad = zeros([batch_size, this.input_dim]);
        grad_kernel = zeros([batch_size, this.int_kernel_dim]);

        grad_pre_act = reshape(layer_grad, ...
        [batch_size, prod(this.layer_dim(1:2)), this.layer_depth]);
        % variables to help with parallelization
        k_dim = this.kernel_dim;
        s_size = this.stride_size;
        r_coeff = this.reg_coeff;
        r_func = this.reg_func_grad;
        k = this.kernel;
        in_dim = this.input_dim;

        for s = 1:batch_size
            aux_input = im2row(shiftdim(input_val(s,:,:,:),1), k_dim, s_size);
            temp = shiftdim(grad_pre_act(s,:,:),1);
            grad_kernel(s,:,:) = aux_input' * temp ...
              + r_coeff * r_func(k); 

            prev_layer_grad(s,:,:,:) = row2im(shiftdim(grad_pre_act(s,:,:),1) * k',...
              k_dim, in_dim, s_size);
        end;
      
      % Now get the stochastic gradient
      grad_kernel = shiftdim(sum(grad_kernel, 1),1);
      grad_bias = shiftdim(sum(grad_bias, 1),1);
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
    
    function [int_kernel_dim, bias_dim] = get_params_dim(this)
        int_kernel_dim = size(this.kernel);
        bias_dim = size(this.bias);
    end;
  end;
end