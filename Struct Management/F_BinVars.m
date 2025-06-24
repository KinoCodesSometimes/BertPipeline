function Binned = F_BinVars(Variable, bw, varargin)
%%		F_BinVars		%%
% Description
	% This function bins a given variable (Variable, matrix), into bins of a 
    % given length (bw). It excludes bins where one or more frames are
    % corrupt (FrameInclusion). If the provided variable is a struct, the 
    % binning will be performed for each individual element.
% Inputs
	% VARIABLE (Dims x Time matrix or Struct) - Matrix/struct containing 
        % the data that must be binned.
	% FrameInclusion (1 x Time) - Logical containing information of which frames 
        % must be excluded
		% 1 = included; 	0 = excluded. 
	% bw - Double indicating the bin width.
% Outputs
	% Binned (Dims x Binned Time) - Variable binned with the given bw, 
        % with bins bearing FrameInclusion = 0 being excluded

% Optional Inputs
	% ExcludeSurround (Logical, TRUE by default) - Will also exclude 
        % frames surrounding a corrupt frame. (Good for derivative values)
    % Method (String) - Determines the method used to compute a bin's value
        % "Mean" (DEFAULT)
        % "Min"
        % "Max"
% JRPP - PetersenLab April 24.

%% Prepping the optional arguments
AddArgs = ["FrameInclusion", "ExcludeSurround", "Method"]; % Additional arguments
ArgValues = F_VararginSelection(AddArgs, ...
    {["matrix", "logical"], 'logical', 'string'}, ... % Type of structure expected
    {'', '', ["Min", "Max", "Mean"]}, ... % Constraints of input
    {false, true, "Mean"}, ... % Default value
    varargin{:});
clear AddArgs
%% Excluding surrounding frames - For the derivatives
if class(ArgValues{"FrameInclusion"}) == class(false) 
    if ArgValues{"FrameInclusion"} == true
        if ArgValues{"ExcludeSurround"}

            % Identifying excluded frames and collecting the surrounding frames
            exc = unique(reshape( ...
                reshape(find(FrameInclusion == 0), 1, []) + ...
                [-1; 0; 1], 1, []));

            % Cropping to trial length
            exc = exc(exc > 0 & exc < length(FrameInclusion));

            % Re-Writing FrameInclusion
            FrameInclusion = ones(size(FrameInclusion));
            FrameInclusion(exc) = 0;
        end
        clear exc
    else
        FrameInclusion = ones(1, size(Variable, 2));
end
    
%% Determining binning function
if ArgValues{"Method"} == "Min"
    BinFun = @(x) min(x, [], 2);
elseif ArgValues{"Method"} == "Max"
    BinFun = @(x) max(x, [], 2);
else % ArgValues{"Method"} == "Mean"
    BinFun = @(x) mean(x, 2);
end

%% Binning
if class(Variable) == "struct" % Obsolete after corrections to the code - Still good to keep for future function use
    Binned = []; % Output
    for f = string(fieldnames(Variable)).' % Looping per field
        Frames = size(Variable.(f), 2);
        NBins = floor(Frames/bw);
        FrameInclusion = FrameInclusion(1:bw*NBins); % Cropping
        Variable.(f) = Variable.(f)(:, 1:bw*NNins); % Cropping
        bins = discretize(0:bw*NBins-1, NBins); % Discretising
        % Iterating per bin and computing value
        for b_ix = 1:max(bins)
            if mean(FrameInclusion(bins == b_ix)) == 1
                Binned.(f) = [Binned.(f), ...
                    BinFun(Variable.(f)(:, bins == b_ix))];
            end
        end
    end
elseif class(Variable) == "double"
    % Defining parameters
    Frames = size(Variable, 2);
    NBins = floor(Frames/bw);
    
    % Cropping end frames
        FrameInclusion = FrameInclusion(1:bw*NBins);
        Variable = Variable(:, 1:bw*NBins);
    
    
    bins = discretize(0:bw*NBins-1, NBins);
    
    % Selecting good bins
    Binned = [];
    for b_ix = 1:max(bins)
        if mean(FrameInclusion(bins == b_ix)) == 1
            Binned = [Binned, ...
                BinFun(Variable(:, bins == b_ix))]; %#ok<AGROW>
        end
    end
    
end
end

