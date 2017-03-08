function col_idx = col_idx_aux(i, j, height_idx, width_idx, h_step, ...
    w_step, padded_image_height, padded_image_width, window_height, window_width, rows_dim )
%COL_IDX_AUX Get the indices of the cols for image element i,j. Note that 
% the channel number is encoded in j. So channel_number =
% j/padded_image_width and the actual width_number mod(j,
% padded_image_width).
channel_num = floor(j/(padded_image_width+1));
j = mod(j, padded_image_width+1);
col_idx = tensor_sum(1+(i-height_idx(i,:)'),window_height*(j-width_idx(j,:)')) ...
    + channel_num*(window_height*window_width);
col_idx(isnan(col_idx) | isinf(col_idx)) = rows_dim(2)+1;
end

