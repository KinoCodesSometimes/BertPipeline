function [] = F_DLC_Object(mad)


        vds = mad.VideoFolder + "\" + ...
            string({dir(fullfile(mad.VideoFolder, "*.avi")).name}); % Identifying videos

        reassurance = ["Still working", ...
            "Taking my time but I'm still DLCing", "DLCing...", ...
            "Yes, it's supposed to take this long", ...
            "No, I havent stopped working", ...
            "Don't panic, I'm still doing my thing", ...
            "Not done yet, DLCing takes time!", ...
            "Yes, I'm still doing my thing...", ...
            "Don't pause me! I'm still working hard"] + "\n";

        wb = waitbar(0, "DeepLabCutting bodycam videos"); %#ok<NASGU> % UI
        wb_c = 1; % UI counter

        for v_pth = vds
            waitbar(wb_c/length(vds));
            rnd = reassurance(randperm(length(reassurance)));
            F_CallDLC(mad.DLCNet, v_pth); % Actual DLCing
            fprintf(rnd(1))
        end
        close wb
        mad.DLCFolder = mad.VideoFolder;

end

