function F_BatchFunMAD(funHandle, MadPaths)
    MadPaths = string(readtable(MadPaths).Paths);
    for mad_ix = 1:length(MadPaths)
        load(MadPaths(mad_ix) + "\mad.mat", "mad") % As mad
        mad.DayFolder

        % try
             funHandle(mad)
        % catch
        %     "ERROR IN" + MadPaths(mad_ix) + "\mad.mat"
        % end

        clear mad
    end
end