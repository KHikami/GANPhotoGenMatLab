function [z, y, l] = forward_cal(nn, hn, rn)
%forward_cal calcalute the results for values for each neuron given the
%input hn and rn. hn and rn are sets of training data which is given by
%hn=row{h1,h2,...hm}. nn is the feedforward neuralnetwork while z and y is
%pre- and post-activation vectors. p denotes the sparsity parameter.

%examine the dimension match
assert(length(hn(1,:))==length(rn(1,:)),...
    'the dimension of training data should be of same length');
assert(length(nn.networkLayer{1}.W(1,:))==length(hn(:,1)),...
    'the dimension of input does not match');
assert(length(nn.networkLayer{nn.numOfLayer-1}.W(:,1))==length(rn(:,1)),...
    'the dimension of input does not match');

numOfData = length(hn(1,:));
numOfLayer = nn.numOfLayer;
z = cell (numOfLayer, numOfData);
y = cell (numOfLayer, numOfData);

for i = 1:numOfData
    z{1,i} = hn(:, i);
    y{1,i} = hn(:, i);
    for j = 1:(numOfLayer-2)
        z{j+1, i} = nn.networkLayer{j}.W * y{j,i} - nn.networkLayer{j}.theta;        
        switch nn.activation_function
            case 'tanh'
                y{j+1, i} = tanh(z{j+1, i});
            case 'sig'
                y{j+1, i} = 1./(1+exp(-z{j+1, i}));
        end
    end
    %output layer
    j=j+1;
    z{j+1, i} = nn.networkLayer{j}.W * y{j,i} - nn.networkLayer{j}.theta; 
    switch nn.output_function
        case 'tanh'
            y{j+1, i} = tanh(z{j+1, i});
        case 'sig'
            y{j+1, i} = 1./(1+exp(-z{j+1, i}));
    end
    
    loss=0;
        for i = 1:length(rn(1,:))
            for j=1:length(rn(:,1))
                loss = loss + (y{nn.numOfLayer,i}(j)-rn(j,i))^2;
            end
        end
        loss = loss/length(rn(1,:));
    l=loss;    
end


            
    



