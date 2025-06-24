function F_PyPMatrix(P, varargin)
    if nargin > 1 % If user specifies output file
        path = char(varargin{1});
        if path(end) == '/' | path(end) == '\' % Compatibility
            path(end) = [];
        end
        path = string(path);
        
    else
        path = "";
    end

    % Iterating per camera
    for i = 1:length(P)
        p_ = py.numpy.array(P{i}); % Transform to numpy
        py.numpy.save(path + "\P"+i+".npy", p_); % Save as numpy
    end
end