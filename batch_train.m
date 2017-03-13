function batch_train(nn, train_para, train_x, train_y)
%train_para
m = length(train_x(1, :));

batchsize = train_para(1);
numrepeat = train_para(2);

numbatches = m / batchsize;

%assert(rem(numbatches, 1) == 0, 'numbatches must be a integer');


for i = 1 : numrepeat
    tic;
    

    kk = randperm(m);
    for l = 1 : numbatches
        batch_x = train_x(:,kk((l - 1) * batchsize + 1 : l * batchsize));
        
        %Add noise to input (for use in denoising autoencoder)
        if(nn.denoisingfactor ~= 0)
            batch_x = batch_x.*(rand(size(batch_x))>nn.denoisingfactor);
        end
        
        batch_y = train_y(:,kk((l - 1) * batchsize + 1 : l * batchsize));
        
        [z, y, p, sens_vec] = forward_para(nn, batch_x, batch_y);
        if length(nn.sparsity{1}) == 0
            for i = 2:nn.numOfLayer
                nn.sparsity{i} = p{i};
            end
        else
            for i = 2:nn.numOfLayer
                nn.sparsity{i} = 0.99*nn.sparsity{i}+0.01*p{i};
            end
        end
                    
        for i = 1: nn.numOfLayer-1
            w_temp = sens_vec{i+1,1}*(y{i,1})';
            theta_temp = sens_vec{i+1,1};
            if batchsize > 1
                for j = 2:batchsize
                    w_temp = w_temp + sens_vec{i+1,j}*(y{i,j})';
                    theta_temp = theta_temp + sens_vec{i+1,1};
                end
            end
            nn.networkLayer{i}.W = (1-2 * nn.train_parameter.p * nn.learning_rate) * nn.networkLayer{i}.W - ...
                nn.learning_rate * (1/batchsize)*w_temp;
            nn.networkLayer{i}.theta = nn.networkLayer{i}.theta - nn.learning_rate * (1/batchsize)*theta_temp + ...
                0*nn.learning_rate * nn.train_parameter.beta*(nn.sparsity{i+1}-nn.sparsity_jug);
        end
    
    t = toc;
    end
end

