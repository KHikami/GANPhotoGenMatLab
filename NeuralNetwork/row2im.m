function image = row2im(rows, window_size, image_size, step_size)
% The transposed operation of im2row. Again, same zero padding is assumed.

% Preallocate memory for the image
padded_image = zeros(image_size+[window_size-1, 0]);
h_step = step_size(1);
w_step = step_size(2);
padded_image_height = size(padded_image,1);
padded_image_width = size(padded_image,2);
image_channels = image_size(3);
window_height = window_size(1);
window_width = window_size(2);

% Loop through rows, reshape it, and add it to image
count = 0;
for w = 1:w_step:padded_image_width-(window_height-1)
    for h = 1:h_step:padded_image_height-(window_width-1)
        count = count + 1;
        padded_image(h:h+window_height-1, w:w+window_width-1, :) ...
            = padded_image(h:h+window_height-1, w:w+window_width-1, :) ...
            + reshape(rows(count, :), ...
            [window_size, image_channels]);
    end;
end;

% Remove the paddings from the image
image = padded_image(1+(window_height-1)/2:end-(window_height-1)/2,...
    1+(window_width-1)/2:end-(window_width-1)/2,:);

end

