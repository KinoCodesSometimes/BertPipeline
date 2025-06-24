function [mad] = F_ProcessObject(mad)
%% Prepping the data
    % IF MANUAL
    if mad.RunParams.ObjectLabel ~= "Auto"
    % Getting the user to select the best frames for labelling
        if string(class(mad.Prog.ObjFram)) == "logical"
            mad = F_ObjectFrameSelection_manual(mad);
            save(mad.RunParams.SaveLoc, "mad") % Saving progress
        end
    
        % Getting object labels
        if string(class(mad.Prog.ObjLabel)) == "logical"
            if mad.RunParams.ObjectLabel == "MATLAB"
                mad = F_UILabelObj(mad);
                save(mad.RunParams.SaveLoc, "mad") % Saving progress
            else
                fprintf("Label the selected frames " + ...
                    "(see video folder) using " + ...
                    "DLC. Once done, restart the code.")
                quit force
            end
        end

    % IF AUTO (via trained DLC network)
    elseif mad.RunParams.ObjectLabel == "Auto"
        % Quick estimation of SOD and frame selection accordingly
            if string(class(mad.Prog.ObjFram)) == "logical"
                mad = F_ObjectFrameSelection_auto(mad);
            end
    
        % Generating the videos with the selected frames
            mad = F_GenerateVideoObject(mad);
    
        % DLCing the generated videos
            vds = mad.RunParams.ObjVideos + "\" + ... % Sorting available .avis
                string({dir(fullfile(...
                mad.RunParams.ObjVideos, "*.avi")).name});
                pyenv(Version = mad.Envs.DLC, ...
                    ExecutionMode = "OutOfProcess"); % JRPP - Adjust with local PC DLC cond env direct.
            for v_pth = vds
                
                F_CallDLC(mad.Obj.ObjDLCNet, v_pth, "Shuffle", ...
                    3); % Actual DLCing
            end        
    end

%% Triangulating the object

    mad = F_TriangulateObject(mad);
    save(mad.RunParams.SaveLoc, "mad")
    

%% Generating object meshes
    mad.Obj.Mesh = cell(1, length(mad.Obj.Triangulated));
    mad.Obj.Additional = mad.Obj.Mesh;
    
    for t_ix = 1:length(mad.Obj.Triangulated)
        [mad.Obj.Mesh{t_ix}, top, mid, bot] = ...  % Extracting meshes    
            object_surface2(mad.Obj.Triangulated{t_ix}, 'half truncated cone');
        mad.Obj.Additional{t_ix} = {top, mid, bot}
    end
    try
        close all
        F_AssessObjects(mad) % JRPP - Get a refresher on what this did...
    end
end

