%% Clear the screen and variables
clear;
clc;
%close all;

%% Parameters
NUM_ITE = inf;
MAX_D_STEP = 2;
MAX_G_STEP = 2;

learning_rate = 0.005;
batch_size = 32;
im_length = 32;
seed_dim = [50,1];
im_dim = [im_length,im_length,1];

%% Initialize the D and G
D = create_discriminator();
G = create_generator();

D_params = normrnd(0, 0.05, [get_num_params(D),1]);
G_params = normrnd(0, 0.05, [get_num_params(G),1]);

%% Generate a bunch of 32x32 images squares. 
real_image_batch = test_gan_images(batch_size, im_dim);
seed_batch = normrnd(0,1,[batch_size,seed_dim]);

fake_image_batch = predict(G,seed_batch);
fake_image_batch = fake_image_batch{G.num_layers+1};

%%
cost_d = nan;
cost_g = nan;

d_score = gan_discriminate(D, real_image_batch, fake_image_batch, D_params);
g_score = gan_generate(G, seed_batch, D, G_params);

balance_threshold = 0.1;

fake_image_batch = predict(G,seed_batch);
    fake_image_batch = fake_image_batch{G.num_layers+1};

for n=1:NUM_ITE
    fprintf('Iteration %i of %i\n', n, NUM_ITE);
    %real_image_batch = test_gan_images(batch_size, im_dim);
    %seed_batch = rand([batch_size,seed_dim]);
    
    fake_image_batch = predict(G,seed_batch);
    fake_image_batch = fake_image_batch{G.num_layers+1};
    
    [d_score, grad_d] = gan_discriminate(D, real_image_batch, fake_image_batch, D_params);
    [g_score, grad_g] = gan_generate(G, seed_batch, D, G_params);
    
    fprintf('\tD-G score: %i\t%i\n', d_score, g_score);
    
    diff = g_score - d_score;
    optimize_d = diff <= balance_threshold;
    optimize_g = diff >= -balance_threshold;
    
    %if n<5
    %    optimize_d = true;
    %    optimize_g = true;
    %end;

    if optimize_d
        for i=1:MAX_D_STEP
            fprintf('\tOptimizing D: %i of %i\n', i, MAX_D_STEP);
            [d_score, grad_d]= gan_discriminate(D, real_image_batch, fake_image_batch, D_params);
            D_params = D_params - learning_rate * grad_d;
            
            figure(1);
            cost_d(end+1) = d_score;
            plot(cost_d(2:end));
            drawnow;
        end;

        [weights, bias] = paramvec2cells(D, D_params);
        set_params(D, weights, bias);
    end;
    if optimize_g
        for j=1:MAX_G_STEP
            fprintf('\tOptimizing G: %i of %i\n', j, MAX_G_STEP);
            [g_score, grad_g] = gan_generate(G, seed_batch, D, G_params);
            G_params = G_params - learning_rate * grad_g;  
            
            figure(2);
            cost_g(end+1) = g_score;
            plot(cost_g(2:end));
            drawnow;
        end;
    
        [weights, bias] = paramvec2cells(G, G_params);
        set_params(G, weights, bias);
    end;
    
    seed = seed_batch(1:4,:,:,:);
    for k=1:4
        fake_image = predict(G,seed(k,:,:,:));
        fake_image = fake_image{G.num_layers+1};
        fake_image = shiftdim(fake_image, 1);
        figure(3);
        subplot(2,2,k);
        imagesc(fake_image);
        drawnow;
    end;
end;


%% Test gradient of D

epsilon = 10^-10;
for idx = 1:10
fake_image_score = predict(D, fake_image_batch);
fake_image_score = fake_image_score{D.num_layers+1};
[d_old, grad_d] =  gan_discriminate(D, real_image_batch, fake_image_batch, D_params);
new_params = D_params;
new_params(idx) = D_params(idx) +epsilon;
[d_new, ~] =  gan_discriminate(D, real_image_batch, fake_image_batch, new_params);
approx_grad = (d_new - d_old)/epsilon;

(grad_d(idx)-approx_grad)/approx_grad
end;

%%
for idx = 1:5
[d_old, grad_d, grad_in] =  gan_discriminate(D, real_image_batch, fake_image_batch, D_params);
new_real_image_batch = real_image_batch;
new_real_image_batch(idx) = real_image_batch(idx) + epsilon;
[d_new] =  gan_discriminate(D, new_real_image_batch, fake_image_batch, D_params);
approx_grad = (d_new - d_old) / epsilon;
(grad_d(idx)-approx_grad)/approx_grad
end;

%% Test gradient of G
for idx = 1:10
[g_old, grad_g] =  gan_generate(G, seed_batch, D, G_params);
new_params = G_params;
new_params(idx) = G_params(idx) +epsilon;
[g_new, ~] =  gan_generate(G, seed_batch, D, new_params);
approx_grad = (g_new - g_old)/epsilon;
(grad_g(idx)-approx_grad)/approx_grad
end;

%%
% epsilon = 10^-11;
% fake_image_score = predict(D, fake_image_batch);
% fake_image_score = fake_image_score{D.num_layers+1};
% [d_old, grad_d] =  eval_at(D, real_image_batch, fake_image_score, D_params);
% 
% new_params = D_params;
% new_params(1) = D_params(1) +epsilon;
% [d_new, ~] =  eval_at(D, real_image_batch, fake_image_score, new_params);
% approx_grad = (d_new - d_old)/epsilon;
% approx_grad
% grad_d(1)


