function [PixelImage] = Pixelize(colorMap)

[origh,origw,origd] = size(colorMap);

%will store the rgb values per winning color
compactVersion = zeros(origh,origw,3);

for i = 1:origh
    for j = 1:origw
        [maxvalue, maxColorIndex] = max(colorMap(i,j,:));
        switch(maxColorIndex)
            case 1 %White wins
                compactVersion(i,j,1) = 255; 
                compactVersion(i,j,2) = 255; 
                compactVersion(i,j,3) = 255; 
            case 2 %Black
                compactVersion(i,j,1) = 0; 
                compactVersion(i,j,2) = 0; 
                compactVersion(i,j,3) = 0;
            case 3 %Gray
                compactVersion(i,j,1) = 220; 
                compactVersion(i,j,2) = 220; 
                compactVersion(i,j,3) = 220;
            case 4 %Red
                compactVersion(i,j,1) = 255; 
                compactVersion(i,j,2) = 0; 
                compactVersion(i,j,3) = 0;
            case 5 %Pink
                compactVersion(i,j,1) = 255; 
                compactVersion(i,j,2) = 153; 
                compactVersion(i,j,3) = 153;
            case 6 %Orange
                compactVersion(i,j,1) = 255; 
                compactVersion(i,j,2) = 165; 
                compactVersion(i,j,3) = 0;
            case 7 %Brown
                compactVersion(i,j,1) = 165; 
                compactVersion(i,j,2) = 42; 
                compactVersion(i,j,3) = 42;
            case 8 %Yellow
                compactVersion(i,j,1) = 255; 
                compactVersion(i,j,2) = 255; 
                compactVersion(i,j,3) = 0;
            case 9 %Green
                compactVersion(i,j,1) = 0; 
                compactVersion(i,j,2) = 128; 
                compactVersion(i,j,3) = 128;
            case 10%Blue
                compactVersion(i,j,1) = 0; 
                compactVersion(i,j,2) = 0; 
                compactVersion(i,j,3) = 255;
            case 11 %Purple
                compactVersion(i,j,1) = 128; 
                compactVersion(i,j,2) = 0; 
                compactVersion(i,j,3) = 128;
            case 12 %Magenta
                compactVersion(i,j,1) = 255; 
                compactVersion(i,j,2) = 0; 
                compactVersion(i,j,3) = 255;
        end
    end
end

%use cat to put the matrices together after kronecker product
onesMatrix = ones(8,8);
PixelImage = cat(3, kron(compactVersion(:,:,1),onesMatrix), kron(compactVersion(:,:,2),onesMatrix), kron(compactVersion(:,:,3),onesMatrix));
