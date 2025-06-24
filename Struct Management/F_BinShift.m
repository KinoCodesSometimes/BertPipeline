function binvar = F_BinShift(var, bw)
%F_BINVARS Summary of this function goes here
%   Detailed explanation goes here

    binvar = cellfun(@fBinning, var);

    function binned = fBinning(x)
        x = x(:, 1:(floor(size(x, 2)/bw).*bw));
    
        % If the input is not one dimensional (firing rate)
        if size(x, 1) > 1
            binned = {permute(mean(reshape(x, size(x, 1), bw, []), 2), ...
                [1, 3, 2])};

        else
            binned = {mean(reshape(x, bw, []))};
        end
    end
    

   
end

