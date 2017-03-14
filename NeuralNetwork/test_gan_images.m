function X = test_gan_images(num_images, im_dim)
%TEST_GAN_IMAGES Create 128 images of size 64x64x3 for gan training

im_length = im_dim(1);
X = zeros([num_images, im_dim]);

for i=1:num_images
    X(i,:,:,:) = gen_square(randi([im_length/4,im_length/2]), randi([1,im_length]), randi([1,im_length]), im_length);
end;


end

