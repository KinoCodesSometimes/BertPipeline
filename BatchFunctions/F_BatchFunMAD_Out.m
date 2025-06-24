function out = F_BatchFunMAD_Out(ProcessFun, CatDim, MadPaths)
    MadPaths = string(readtable(MadPaths).Paths);
    out = [];
    for mad_ix = 1:length(MadPaths)
        MadPaths(mad_ix)
        load(MadPaths(mad_ix) + "\mad.mat", "mad") % As mad
        mad.DayFolder
        mad

        % try
            out = cat(CatDim, out, ProcessFun(mad));
                   % catch
        %     "ERROR IN" + MadPaths(mad_ix) + "\mad.mat"
        % end
        % 
        % clear mad
    end
end