function Var_splt = F_SplitVar(Var, Len, varargin)
ArgValues = F_VararginSelection("Dim", ...
    {'double'}, ...
    {''}, ...
    {0}, varargin{:});

% If dimension not specified
    if ArgValues{"Dim"} == 0
        ArgValues{"Dim"} = find(max(size(Var)));
    end

% Determining segments
    if round(size(Var, ArgValues{"Dim"})/Len) == ...
            size(Var, ArgValues{"Dim"})/Len
        warning("Var cannot be split into even segments")
    end
    segs = round(size(Var, ArgValues));
    
% Storage
    Var_splt = cell(1, segs);

% Transposing given dimension
    if ArgValues{"Dim"} == 1
        Var = Var.';
    end

% Segmenting
    for seg_ix = 1:segs
        Var_splt{segs} = Var(:, ((seg_ix-1)*Len+1):(seg_ix*Len));
    end

% Correcting the transpose given the dimension
    if ArgValues{"Dim"} == 1
        Var_splt = cellfun(@transpose, Var_splt);
    end
end