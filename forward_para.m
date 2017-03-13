function [z, y, p, sens_vec] = forward_para(nn, hn, rn)

%examine the dimension match
assert(length(hn(1,:))==length(rn(1,:)),...
    'the dimension of training data should be of same length');
assert(length(nn.networkLayer{1}.W(1,:))==length(hn(:,1)),...
    'the dimension of input does not match');
assert(length(nn.networkLayer{nn.numOfLayer-1}.W(:,1))==length(rn(:,1)),...
    'the dimension of input does not match');

numOfData = length(hn(1,:));
numOfLayer = nn.numOfLayer;
sens_vec = cell (numOfLayer, numOfData);

numOfData = length(hn(1,:));
numOfLayer = nn.numOfLayer;
z = cell (numOfLayer, numOfData);
y = cell (numOfLayer, numOfData);
p = cell (numOfLayer, 1);
sens_vec = cell (numOfLayer, numOfData);
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
end

for i=2:numOfLayer
    p{i} = 1/numOfData * y{i, 1};
    for j=2:numOfData
        p{i} = p{i} + 1/numOfData * y{i, j};
    end
end

switch nn.output_function
    case 'tanh'
         for i = 1: numOfData
                sens_vec{numOfLayer, i} = (1 - (tanh(z{numOfLayer,i})).^2).*...
                    (y{numOfLayer, i} - rn(: ,i))*2;
         end
    case 'sig'
        for i = 1: numOfData
                sens_vec{numOfLayer, i} = (exp(-z{numOfLayer,i})./(1+exp(-z{numOfLayer,i})).^2).*...
                    (y{numOfLayer, i} - rn(: ,i))*2;
        end
end        
switch nn.activation_function
     case 'tanh'
            for i = 1: numOfData
                for j = numOfLayer-1:-1:2
                    sens_vec{j, i} = (1 - (tanh(z{j,i})).^2).*...
                        ((nn.networkLayer{j}.W)'*sens_vec{j+1, i});
                end
            end
    case 'sig'
            for i = 1: numOfData
                for j = numOfLayer-1:-1:2
                    sens_vec{j, i} = (exp(-z{numOfLayer,i})./(1+exp(-z{numOfLayer,i})).^2).*...
                        ((nn.networkLayer{j}.W)'*sens_vec{j+1, i});
                end
            end
end


