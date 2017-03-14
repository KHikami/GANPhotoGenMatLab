function image = row2im(rows, window_size, image_size, step_size)
% The transposed operation of im2row. Again, same zero padding is assumed.

% Preallocate memory for the image
if length(image_size)==2
    image_size = [image_size, 1];
end;
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
            + reshape(rows(count, :), [window_size, image_channels]);
    end;
end;

% Remove the paddings from the image
image = padded_image(1+(window_height-1)/2:end-(window_height-1)/2,...
    1+(window_width-1)/2:end-(window_width-1)/2,:);

% % Preallocate memory for image
% % Pad the image at the top and the left
% padded_image = zeros(image_size+[(window_size-1)/2, 0]);
% h_step = step_size(1);
% w_step = step_size(2);
% padded_image_height = size(padded_image,1);
% padded_image_width = size(padded_image,2);
% image_channels = image_size(3);
% window_height = window_size(1);
% window_width = window_size(2);
% rows_dim = size(rows);
% 
% rows = [rows, zeros(size(rows, 1),1)];
% rows = [rows; zeros(1, size(rows, 2))];
% 
% height_idx = bsxfun(@minus,(1:padded_image_height)',0:(window_height-1));
% height_logic = ~mod(height_idx-1, h_step) & height_idx >=1 ...
%     & height_idx <=padded_image_height-(window_height-1)/2;
% height_idx = height_idx ./ height_logic;
% width_idx = bsxfun(@minus,(1:padded_image_width)',0:(window_width-1));
% width_logic = ~mod(width_idx-1, w_step) & width_idx >=1 ...
%     & width_idx <= padded_image_width - (window_width-1)/2;
% width_idx = width_idx ./ width_logic;
% 
% % Encode the channel number in j. So channel number = floor(j)/padded_image_width
% row_idx = @(i,j) row_idx_aux(i, j, height_idx, width_idx, h_step, ...
%     w_step, padded_image_height, padded_image_width, window_height, window_width, rows_dim );
% col_idx = @(i,j) col_idx_aux(i, j, height_idx, width_idx, h_step, ...
%     w_step, padded_image_height, padded_image_width, window_height, window_width, rows_dim ); 
% 
% image_val = @(i,j) sum(sum(rows(sub2ind(size(rows), row_idx(i,j), col_idx(i,j)))));
% 
% parfor n=0:numel(padded_image)-1    
%     padded_image(n+1) = image_val(mod(n, padded_image_height)+1, ...
%        mod(floor(n/(padded_image_height)), padded_image_width)+1 ...
%         +floor(floor(n/(padded_image_height))/(padded_image_width))*padded_image_width);
% end;
% image = padded_image(1+(window_height-1)/2:end,1+(window_width-1)/2:end,:);
end

