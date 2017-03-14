clear nn; 
nn=neuralnetwork([100,40,1], 'tanh',3,'tanh',[0.2,0.05],0.5,-0.95,0);
 train_x = rand(100,10);
 train_y = rand(1,10);
 train_para = [1,1];
 ll= zeros(100,1);
 sparsity = zeros(100,1);
 for i = 1: 100
     batch_train(nn, train_para, train_x, train_y);
     [y,z,l] = forward_cal(nn,train_x,train_y);
     ll(i) = l;
     plot (ll); drawnow;
 end
 
 add
 
 ll=zeros(100,1)
 for i = 1:100
     l=train_sae([100,80,40,80,100],[1,i],ones(100,1));
     ll(i)=l;
     plot(ll);drawnow;
 end
 