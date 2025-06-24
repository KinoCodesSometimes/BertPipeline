function mad = F_DLC(mad)


        vds = mad.VideoFolder + "\" + ...
            string({dir(fullfile(mad.VideoFolder, "*.avi")).name}); % Identifying videos
        for v_pth = vds
            pyenv(Version = mad.Envs.DLC, ...
                ExecutionMode = "OutOfProcess"); % JRPP - Adjust with local PC DLC cond env direct.

            F_CallDLC(mad.DLCNet, v_pth); % Actual DLCing
        end
        mad.DLCFolder = mad.VideoFolder; % Updating

end

