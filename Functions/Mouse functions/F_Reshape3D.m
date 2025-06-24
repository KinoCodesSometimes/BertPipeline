function [Mouse3D] = F_Reshape3D(mouse3D)
%F_RESHAPE3D Transforms NxMxF to (NxM)xF

Mouse3D = zeros(size(mouse3D, 3), ...
    size(mouse3D, 1)*3);


for i = 1:size(mouse3D, 3)
    Mouse3D(i, :) = reshape(mouse3D(:, :, i).', 1, []);
end
imagesc(Mouse3D)
end