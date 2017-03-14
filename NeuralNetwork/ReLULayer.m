classdef ReLULayer < handle
    %RELULAYER Applies ReLU elementwise to the input
    
    properties
        leaky_constant;
    end
    
    methods
        function object = ReLULayer(leaky_constant)
            if exist('leaky_constant', 'var')
                object.leaky_constant = leaky_constant;
            else
                object.leaky_constant = 0;
            end;
        end;
        
        function [output_val] = compute_output(this, input_val)
          % Compute the output of this layer usig the input.
          % Inputs:
          %   input_val: a batch_size x input_dim_1 x input_dim_2 x input_dim_3
          %     tensor storingthe input.
          % Outputs:  
          %   output_val: the output values from this layer
          output_val = max(input_val, this.leaky_constant*input_val);
        end;
        
        function [prev_layer_grad, grad_weight, grad_bias] ...
            = compute_grad(this, input_val, layer_grad)
          % Computes regularized cost's gradient with respect to the input, the
          % layer weight, and the layer bias at input. It uses layer_grad to
          % to back propagate.
          % Inputs:
          %   input: a batch_size x input_dim_1 x input_dim_2 x
          %   input_dim_3test.c
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
          
          prev_layer_grad = layer_grad .* ...
            max(sign(input_val),-this.leaky_constant*sign(input_val));

          grad_weight = [];
          grad_bias = [];  
        end;
        
        function [weight, bias] = get_params(this)
            % Return the weight and bias of this layer
            weight = [];
            bias = [];
        end;

        function set_params(this, weight, bias)
            % Set the weight and bias
        end;

        function [weight_dim, bias_dim] = get_params_dim(this)
            weight_dim = [0,0];
            bias_dim = [0,0];
        end;
    end
end
