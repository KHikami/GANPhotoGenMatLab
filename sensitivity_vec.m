function sens_vec=sensitivity_vec(nn, hn, rn)

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


[z, y] = forward_cal(nn, hn, rn);
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


end


                        
            
                    
                
end