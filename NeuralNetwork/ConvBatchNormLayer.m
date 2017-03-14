classdef ConvBatchNormLayer < handle
    %LAYERTEMPLATE A layer in the NN
    properties
        input_dim;
        
        scale_param;
        shift_param;
        
        num_channels;
        
        epsilon = 10^-15;
    end
    
    properties (GetAccess = private)
        init_var = 0.02;
    end;
    
    methods
        function object = ConvBatchNormLayer(input_dim)
            % The constructor. Add more parameters as needed
            object.input_dim = input_dim;
            object.num_channels = input_dim(3);
            
            object.init_var = 0.02;
            object.scale_param = normrnd(0,object.init_var, [1,object.num_channels]);
            object.shift_param = normrnd(0,object.init_var, [1,object.num_channels]);
        end;
        
        function output_val = compute_output(this, input_val)
            % Compute the output of this layer usig the input.
            % Inputs:
            %   input_val: a batch_size x input_dim_1 x input_dim_2 x input_dim_3
            %     tensor storingthe input.
            % Outputs:  
            %   output_val: the output values from this layer
            patch_size = size(input_val,1);
            input_val = reshape(input_val, [], this.num_channels);
            
            centered_input = bsxfun(@minus, input_val, mean(input_val,1));
            stable_input_var = var(input_val, 1, 1) + this.epsilon;
            norm_input = bsxfun(@rdivide, centered_input, sqrt(stable_input_var));
            output_val = bsxfun(@plus,...
                bsxfun(@times, norm_input, this.scale_param),this.shift_param);
            output_val = reshape(output_val, [patch_size, this.input_dim]);
        end;
        
        function [prev_layer_grad, grad_scale, grad_shift] ...
            = compute_grad(this, input_val, layer_grad)
            % Cost's gradient with respect to the input, the
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
            
            batch_size = size(input_val,1);
            input_val = reshape(input_val, [], this.num_channels);
            layer_grad = reshape(layer_grad, [], this.num_channels);
            eff_patch_size = size(input_val, 1);
            
            centered_input = bsxfun(@minus, input_val, mean(input_val,1));
            stable_input_var = var(input_val, 1, 1) + this.epsilon;
            norm_input = bsxfun(@rdivide, centered_input, sqrt(stable_input_var));
            
            grad_scale = sum(layer_grad .* norm_input, 1);
            grad_shift = sum(layer_grad, 1);

            grad_norm = bsxfun(@times, layer_grad, this.scale_param); 
            grad_var = sum(grad_norm.*norm_input,1) .* (-1/2 ./ stable_input_var);
            grad_mean = sum(grad_norm,1) ./ (-sqrt(stable_input_var));
            prev_layer_grad = bsxfun(@plus,...
                bsxfun(@rdivide, grad_norm, sqrt(stable_input_var))+...
                bsxfun(@times, grad_var, 2*centered_input/eff_patch_size),...
                grad_mean/eff_patch_size);
            
            prev_layer_grad = reshape(prev_layer_grad, [batch_size, this.input_dim]);
            
        end;
        
        function [scale, shift] = get_params(this)
            % Return the scale and shift parameter of this layer
            scale = this.scale_param;
            shift = this.shift_param;
        end;

        function set_params(this, scale, shift)
            % Set the scale and shift parameter
            this.scale_param = scale;
            this.shift_param = shift;
        end;

        function [scale_dim, shift_dim] = get_params_dim(this)
            scale_dim = size(this.scale_param);
            shift_dim = size(this.shift_param);
        end;
    end
end
