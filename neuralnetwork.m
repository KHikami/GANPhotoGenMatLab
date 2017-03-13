%the parameter for the normrnd can be optimized
classdef neuralnetwork < handle
    properties (GetAccess = public)
        networkLayer; %including the w and theta matrix of each layer
        numOfLayer;
        output_function;
        activation_function;
        train_parameter;   %including the weight for the regularization and 
                           %that of the sparsity penalty coefficient
        learning_rate;
        sparsity;
        sparsity_jug;      %minimum -1 for tanh and 0 for sig
        denoisingfactor;
    end
    
    methods
        function nn = neuralnetwork(networkdim,...
                output_function,numOfLayer,activation_func,...
                train_parameter,learning_rate,sparsity_jug,...
                denoisingfactor)
            %networkdim are denoted as eg.[100,40,40,10] represented 
            %the dimension of each layer 
            
            assert(length(networkdim)==numOfLayer,...
                'dimension of networkdim does not match');
            switch activation_func
                case 'tanh'
                    nn.activation_function = 'tanh';
                case 'sig'
                    nn.activation_function = 'sig';  %1/(1+exp(-x))
                otherwise
                    assert(1~=1,'activation_func is illegal');
            end
            switch output_function
                case 'tanh'
                    nn.output_function = 'tanh';
                case 'sig'
                    nn.output_function = 'sig';  %1/(1+exp(-x))
                otherwise
                    assert(1~=1,'output_function is illegal');
            end
            nn.numOfLayer = numOfLayer;
            %initial the W and theta matrix according to normal
            %distribution
            nn.networkLayer = cell(numOfLayer-1,1);
            for i = 1: length(networkdim)-1
                nn.networkLayer{i}.W = normrnd(0,0.01,networkdim(i+1),networkdim(i));
                nn.networkLayer{i}.theta = normrnd(0,0.01, networkdim(i+1),1);
            end
            
            if length(train_parameter)==1
                train_parameter = [train_parameter, 0];
            end
            nn.train_parameter.p = train_parameter(1);
            nn.train_parameter.beta = train_parameter(2);
 
            nn.learning_rate = learning_rate;
            nn.sparsity_jug = sparsity_jug;
            nn.sparsity = cell(numOfLayer, 1);
            nn.denoisingfactor =denoisingfactor;
            
        end
        
        function add_layer(this, layer_info) %sparsity needs to be fixed here
            %layer_info are record in the format of layer_info = cell (N,1)
            %where N is the total number of layers going to be added.
            %layer_info{k}.layer is the layer number in the previous
            %NN,eg.if the new adding layer starts from 4 then layer_info{1}.layer =4,
            %layer_info.W and layer_info.theta is the parameters for the
            %NN  from   |         |         |                   | 
            %           | -> | -> |    to   | -> | -> | -> | -> |
            %           | -> | -> |         | -> |         | -> |
            assert( layer_info{1}.layer - 1 <= this.numOfLayer,'cant find the insert place');
            
            TotalN = size(layer_info,1);
            W_temp = cell(this.numOfLayer - 1 + TotalN,1);
            theta_temp = cell(this.numOfLayer - 1 +TotalN,1);
            for i = 1 : layer_info{1}.layer - 2
                W_temp {i} = this.networkLayer{i}.W;
                theta_temp {i} = this.networkLayer{i}.theta;
            end
            for i = layer_info{1}.layer - 1 : layer_info{1}.layer - 2 + TotalN
                W_temp {i} = layer_info{i - layer_info{1}.layer + 2}.W;
                theta_temp{i} = layer_info{i - layer_info{1}.layer + 2}.theta;
                assert(size(W_temp{i}, 2) == size(W_temp{i -1},1), 'the size of W does not match');
            end
            
            if(layer_info{1}.layer <= this.numOfLayer)
                assert(size(W_temp{i}, 1) == size(this.networkLayer{i - TotalN + 1}.W, 2), 'the size of W does not match');
                for i = layer_info{1}.layer - 1 +TotalN : this.numOfLayer - 1 +TotalN
                    W_temp {i} = this.networkLayer{i-TotalN}.W;
                    theta_temp{i} = this.networkLayer{i-TotalN}.theta;
                end
            end
            this.numOfLayer = this.numOfLayer + TotalN;
            this.networkLayer = cell(this.numOfLayer - 1,1)
            for i = 1:this.numOfLayer - 1
                this.networkLayer{i}.W = W_temp{i};
                this.networkLayer{i}.theta = theta_temp{i};
            end
                     
        end
        
       
                    
            
                
                
                
         
        
       
    end
end

           
            
            
            
            
            
     
            