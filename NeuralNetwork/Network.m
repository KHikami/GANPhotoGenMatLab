classdef Network < handle
  % Only feedforward network for now
  properties
    network_layers; % The layers of the neural network
    num_layers;     % The number of layers of the network
    
    feature_dim;    % Dimension of the features
    
    layers_output;  % The output of each feature. Kept here for debugging.
    
    cost_func;      % The cost function without the regularization
    cost_func_grad; % The gradient of the said cost function
    reg_func;       % The type of regularization used.
    reg_func_grad;  % The gradient fo the regularization function
    reg_coeff;      % The regularization coefficient.
  end;
  
  properties (GetAccess=private)
    reg_helper;
  end;
  
  methods
    function object = Network(feature_dim, cost_func, ...
            cost_func_grad, reg_func, reg_func_grad, reg_coeff)
      % Initialize the object.
      
      object.feature_dim = feature_dim;
      object.cost_func = cost_func;
      object.cost_func_grad = cost_func_grad;
      object.reg_func = reg_func;
      object.reg_func_grad = reg_func_grad;
      object.reg_coeff = reg_coeff;
      
      object.network_layers = cell(0);
      object.num_layers = 0;
      
      object.reg_helper = @(w) sum(object.reg_func(w));
    end;
    
    function add_fulllayer(this, input_dim, layer_dim, act, ...
            act_grad, layer_name)
      % Add a layer to the network. 
      this.num_layers = this.num_layers + 1;
      this.network_layers{this.num_layers} = FullLayer(input_dim, ...
          layer_dim, act, act_grad, this.reg_func, ...
          this.reg_func_grad, this.reg_coeff, layer_name);
    end;
    
    function add_convlayer(this, input_dim, kernel_dim, layer_depth, ...
        stride_size, act_func, act_func_grad, layer_name)
      % Add a layer to the network. 
      this.num_layers = this.num_layers + 1;
      this.network_layers{this.num_layers} ...
        = ConvLayer(input_dim, kernel_dim, layer_depth, ...
        stride_size, act_func, act_func_grad, this.reg_func, ...
        this.reg_func_grad, this.reg_coeff, layer_name);
    end;
    
    function add_transconvlayer(this, input_dim, kernel_dim, layer_depth, ...
        stride_size, act_func, act_func_grad, layer_name)
      % Add a layer to the network. 
      this.num_layers = this.num_layers + 1;
      this.network_layers{this.num_layers} ...
        = ConvLayer(input_dim, kernel_dim, layer_depth, ...
        stride_size, act_func, act_func_grad, this.reg_func, ...
        this.reg_func_grad, this.reg_coeff, layer_name, 'transpose');
    end;
    
    function [output] = predict(this, input_val)
        forward_val = input_val;
      for l = 1:this.num_layers
        this.layers_output{l} = compute_output(this.network_layers{l}, ...
            forward_val);
        forward_val = this.layers_output{l};
      end;
      
      output = this.layers_output{this.num_layers};
    end;
  
    function [output, cost] = fprop(this, input_val, label)
      % Evalutes the neural network at input_val using forward propagation
      % Inputs:
      %   input_val: a tensor of dimension batch_size x dim_1 x dim_2 x
      %     dim_3 consists of the input data
      %   label: a tensor of dimension batch_size x dim_1' x dim_2' x
      %     dim_3' consists of the corresponding label
      % Outputs:
      %   output: a matrix where each row corresponds to an output vector.
      %   cost: the regularized cost of the network with input_val and
      %     label.
      output = predict(this, input_val);
      
      output_dim = size(output);
      costs = zeros(output_dim(1),1);
      cost_fun = this.cost_func;
      parfor s=1:size(output,1)
        costs(s) =  cost_fun(shiftdim(output(s,:,:,:),1),shiftdim(label(s,:,:,:),1));
      end;
      cost = mean(costs) ...
          + this.reg_coeff * sum(cellfun(this.reg_helper, get_params(this)));
     end;
     
    function [layers_grad_weight, layers_grad_bias] = bprop(this, ...
             input_val, label)
      % Evalutes the neural network's derivative with respect to the 
      % parameters with data input_val using backward propagation
      % Inputs:
      %   input_val: a tensor of dimension batch_size x dim_1 x dim_2 x
      %     dim_3 consists of the input data.
      %   label: a tensor of dimension batch_size x dim_1' x dim_2' x
      %     dim_3' consists of the corresponding label
      % Outputs:
      %   layers_weight_grad: a cell of length num_layers, with each entry 
      %     being a a tensor containing the regularized cost function's 
      %     stochastic gradient with respect to the weights in each layer. 
      %   layers_bias_grad: a cell of length num_layers, with each entry 
      %     being a a tensor containing the regularized cost function's 
      %     stochastic gradient with respect to the biases in each layer.             
      
      [output_val, ~] = fprop(this, input_val, label);
      output_dim = size(output_val);
      back_grad = zeros(output_dim);
      cost_grad = this.cost_func_grad;
      parfor s=1:output_dim(1)
        back_grad(s,:,:,:) = cost_grad(shiftdim(output_val(s,:,:,:),1), ...
            shiftdim(label(s,:,:,:),1));
      end;
      
      for l = this.num_layers:-1:1
        if l>1
          [back_grad, layers_grad_weight{l}, layers_grad_bias{l}] ...
              = update_grad(this.network_layers{l}, ...
              this.layers_output{l-1}, back_grad);
        else
          [back_grad, layers_grad_weight{l}, layers_grad_bias{l}] ...
              = update_grad(this.network_layers{l}, input_val, back_grad);
        end;
      end;
     end;
     
     function [cost, grad] = eval_at(this, input_val, label, weights, biases)
       % Set the parameters of the network to weights and biases and
       % compute the outs and costs using input_val and label
       % Inputs:
       %   input_val: a tensor of dimension batch_size x dim_1 x dim_2 x
       %     dim_3 consists of the input data.
       %   label: a tensor of dimension batch_size x dim_1' x dim_2' x
       %     dim_3' consists of the corresponding label
       %   weights: a num_layers x 1 cell containing the weights of each 
       %     layer
       %   biases: a num_layers x 1 cell sotring the biases of each layer
       % Outputs:
       %   output: a matrix where each row corresponds to an output vector.
       %   cost: the regularized cost of the network with input_val and
       %     label
       if nargin==4
           param_vector = weights;
           weights = cell(this.num_layers,1);
           biases = cell(this.num_layers,1);
           idx = 1;
           for l=1:this.num_layers
             [weight_dim, bias_dim] = get_params_dim(this.network_layers{l});
             length = prod(weight_dim);
             weights{l} = reshape(param_vector(idx:idx+length-1), weight_dim);
             idx = idx + length;
             length = prod(bias_dim);
             biases{l} = reshape(param_vector(idx:idx+length-1), bias_dim);
             idx = idx + length;
           end;
       end;
       
       set_params(this, weights, biases);
       [~, cost ] = fprop(this, input_val, label);         
       [grad_weights, grad_biases] = bprop(this, input_val, label);
       
       grad = zeros(get_num_params(this),1);
       idx = 1;
       for l=1:this.num_layers
         length = numel(grad_weights{l});
         grad(idx:idx+length-1) = grad_weights{l}(:);
         idx = idx + length;
         length = numel(grad_biases{l});
         grad(idx:idx+length-1) = grad_biases{l}(:);
         idx = idx + length;
       end;
     end;
     
     function cost = grad_descent(this, input_val, label, learning_rate)
      % Perform one step of gradient desent the modify the weights and 
      % biases to do gradient descent once.
      % Inputs:
      %   input_val: a tensor of dimension batch_size x dim_1 x dim_2 x
      %     dim_3 consists of the input data.
      %   label: a tensor of dimension batch_size x dim_1' x dim_2' x
      %     dim_3' consists of the corresponding label
      %   learning_rate: a scalar specifying the learning rate
      
      bprop(this, input_val, label);
      for l = 1:this.num_layers
        descent(this.network_layers{l}, learning_rate);
      end;
      [~, cost] = fprop(this, input_val, label);
     end;
  
     function [weight, bias] = get_params(this)
         % Get the weights and bias of each layer
         weight = cell(this.num_layers, 1);
         bias = cell(this.num_layers, 1);
         for l =1:this.num_layers
             [weight{l}, bias{l}] = get_params(this.network_layers{l});
         end;
     end;
     
     function num_params = get_num_params(this)
         num_params = 0;
         [weight, bias] = get_params(this);
         for l=1:this.num_layers
             num_params = num_params + numel(weight{l}) + numel(bias(l));
         end;
     end;
     
     function set_params(this, weight, bias)
         % Set the weights and bias of each layer
         for l =1:this.num_layers
             set_params(this.network_layers{l}, weight{l}, bias{l})
         end;
     end;
     
     function [grad_weight, grad_bias] = get_grad(this)
         % Get the gradient with respect to the weight and bias of each 
         % layer
         grad_weight = cell(this.num_layers, 1);
         grad_bias = cell(this.num_layers, 1);
         for l =1:this.num_layers
             [grad_weight{l}, grad_bias{l}] = get_grad(this.network_layers{l});
         end;
     end;
  end; 
end
    