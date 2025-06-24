function [] = F_CallDLC(config, video, varargin)
% 
AddArgs = "Shuffle";
        ArgValues = F_VararginSelection(AddArgs, ...
            {'double'}, ...
            {''}, ...
            {0}, varargin{:});
        clear AddArgs


pyrunfile(pwd + "\Functions\DLCing\MAtlabToDLC\FPy_DLC.py" + ...
        " '" + config + "' '" + video + "' '" + ArgValues{"Shuffle"} + "'")
end

