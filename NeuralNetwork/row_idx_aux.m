function row_idx = row_idx_aux(i, j, height_idx, width_idx, h_step, ...
    w_step, padded_image_height, padded_image_width, window_height, window_width, rows_dim )
%ROW_IDX_AUX Get the indices of the rows for image element i,j. Note that 
% the channel number is encoded in j. So channel_number =
% j/padded_image_width and the actual width_number mod(j,
% padded_image_width).
j = mod(j, padded_image_width+1);
row_idx = tensor_sum(1 + (height_idx(i,:)' - 1)/h_step, ...
    (1+(padded_image_height-(window_height-1)/2-1)/h_step)*(width_idx(j,:)'-1)/w_step);
row_idx(isnan(row_idx) | isinf(row_idx)) = rows_dim(1)+1;
end

