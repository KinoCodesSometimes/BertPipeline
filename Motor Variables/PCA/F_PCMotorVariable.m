function mad = F_PCMotorVariable(mad)
    %% PREPPING
    % Loading the reference pose
    if mad.RunParams.PCA == "Session"
        a = load(mad.RunParams.ReferenceMouse);
        f = fieldnames(a); % For plasticity
        f = f{1};
        Ref = a.(f);
        clear a f
        
    elseif mad.RunParams.PCA == "PoseBank"
        mad.RunParams.PCA_PoseBank
        load(mad.RunParams.PCA_PoseBank); % mean_pose, refpose and vec
        % JRPP - mean_pose and vec, but not refpose, has implant excluded 
        % in the OG dataset. This inconsistency makes the code 1) less 
        % plastic and 2) prone to error. Discuss this at some point 
        % w/ Matt/Rasmus.
        % OR add a corrective if statement (although not ideal).
        % if size(refpose, 1) ~= (size(mean_pose, 1)/3)
        
        mad.SupMotor.EigenVects = vec;
        clear vec
        Ref = refpose;
        if ~isempty(mad.RunParams.ReferenceMouse) % Notifying of reference pose change
            warning("on")
            warning("The specified reference pose used for " + ...
                "procrustes alignment, stated in 'mad.RunParams" + ...
                ".ReferenceMouse' was ignored. The reference " + ...
                "pose stored in the PCA Pose Bank was used instead.")
            warning("off")
        end
    else
        error("mad.RunParams.PCA in Initiate_mad.m must be set to" + ...
            "Session or PoseBank.")
    end

    % Distinguishing implant landmarks to exclude it from the analyses
    if mad.RunParams.ExcludeImplant
        Ref(mad.RunParams.ExcludedLandmarks, :) = [];
    end

    %% PROCRUSTES   
    mad.Mouse.Aligned = zeros(size(mad.Mouse.Refined));
    mad.SupMotor.ProcrustDust = zeros(size(mad.Mouse.Refined, 3), 1);
    
    for f_ix = 1:size(mad.Mouse.Refined, 3) % Frame
        [mad.SupMotor.ProcrustDust(f_ix), ...
            mad.Mouse.Aligned(:, :, f_ix)] = ...
            procrustes(Ref, mad.Mouse.Refined(:, :, f_ix), ...
            "reflection", false, "scaling", false);
    end

    if mad.RunParams.ViewAlignment
        for f_ix = 1:500:size(mad.Mouse.Aligned, 3)
            F_PlotPose(mad.RunParams.MouseVis, ...
                mad.Mouse.Aligned(:, :, f_ix), "LineAlpha", .5, ...
                "LandmarkAlpha", .9, "Mode", mad.RunParams.FigMode, "LandmarkSize", 50);
        end

        view(-35, 10)
        f = gcf;
        f.Position = [20, 20, 1240, 720];
        % exportgraphics(gcf, mad.RunParams.FigSaveLoc + "\AlignedMouse.pdf", ...
        %     "ContentType", "vector")
        pause(3)

    end

    

    %% PCA
    % Reshaping mouse 3D data
    mouse2d = reshape(mad.Mouse.Aligned, ...
        [size(mad.Mouse.Aligned, 1)*3, size(mad.Mouse.Aligned, 3)])';
    if mad.RunParams.PCA == "Session"
        [mad.SupMotor.EigenVects, mad.SupMotor.PCA, ~, ~, ...
            mad.SupMotor.PC_VarExp] = pca(mouse2d - mean(mouse2d)); % PCA
        mad.SupMotor.PCA= mad.SupMotor.PCA.'; % Storage
        mad.SupMotor.MeanPose = mean(mouse2d);
        % Scree
        mad.SupMotor.PC_NComps = ...
            F_Scree(mad.SupMotor.PC_VarExp, 99, "Mode", ...
            mad.RunParams.FigMode);
        saveas(gcf, mad.RunParams.FigSaveLoc + "\PCA_Scree")
        exportgraphics(gcf, mad.RunParams.FigSaveLoc + "\PCA_Scree.pdf", ...
            "ContentType", "vector")
        % save("PCVideoData.mat", "EigVals", "EigVects", "MeanPose")
        close all
    elseif mad.RunParams.PCA == "PoseBank"
        mad.SupMotor.PCA = ...
            mad.SupMotor.EigenVects.'*(mouse2d.'-mean(mouse2d).'); %mean_pose);
        mad.SupMotor.MeanPose = mean_pose;
        mad.SupMotor.PC_NComps = 3;
    end



    %% PCA visualisations
    if mad.RunParams.PCRel
        if mad.RunParams.PCA ~= "PoseBank"
            F_ViewPCA_Rel(mad)
            if mad.RunParams.PCVideo == true
                F_VisualisePC(mad, 1:mad.SupMotor.PC_NComps);
            end
        end
    end

    
    close all

    %% Splitting each PC and selecting only pertinent PCs
    for pc_ix = 1:mad.RunParams.nPCs
        mad.Motor.("PC" + pc_ix) = mad.SupMotor.PCA(pc_ix, :);
    end
end

