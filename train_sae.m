function l=train_sae(train_size, train_para, train_x)
%train size is given by [100,40,20,40,100] for example;
%
clear nn; 
nn=neuralnetwork([train_size(1),train_size(2),train_size(1)], 'tanh',3,'tanh',[0.2,0.05],0.5,-0.95,0);
batch_train(nn, train_para, train_x, train_x);
[ztemp, ytemp, ltemp] = forward_cal(nn, train_x, train_x);
train_xtemp = ytemp{2};
if(length(train_size)>3)
    for i = 2:(length(train_size)-1)/2
        nntemp = neuralnetwork([train_size(i),train_size(i+1),train_size(i)], 'tanh',3,'tanh',[0.2,0.05],0.5,-0.95,0);
        batch_train(nntemp, train_para, train_xtemp, train_xtemp);
        layer_info = cell(2,1);
        layer_info{1}.layer = i + 1;
        layer_info{1}.W = nntemp.networkLayer{1}.W;
        layer_info{2}.W = nntemp.networkLayer{2}.W;
        layer_info{1}.theta = nntemp.networkLayer{1}.theta;
        layer_info{2}.theta = nntemp.networkLayer{2}.theta;
        add_layer(nn, layer_info);
        [ztemp, ytemp, ltemp] = forward_cal(nntemp, train_xtemp, train_xtemp);
        train_xtemp = ytemp{2};
        clear nntemp;
    end
end
[z, y, l] = forward_cal(nn, train_x, train_x);


