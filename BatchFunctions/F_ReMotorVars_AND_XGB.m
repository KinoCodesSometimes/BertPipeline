function [mad] = F_ReMotorVars_AND_XGB(mad)
    terminate(pyenv)
    mad.RunParams.PCA_PoseBank = "SC_PoseBank.mat"; % Re-setting PCs

    mad.Motor  = [];

    LocalEnvs;
    % %% Mouse triangulation
    % mad = F_Triangulation(mad); % JRPP - DONE 
    % save(mad.RunParams.SaveLoc + "\mad.mat", "mad")

    %% Extracting motor variables
    % Computing non-split vars - Those that do not consider more than one frame
    % at once
        mad = F_PCMotorVariable(mad); % PCA - mad.Motor.PCA % JRPP - DONE % Do embedded instead
        mad = F_GetHeadAngles(mad); % Head angles - mad.Motor.Yaw/Pitch/Roll % JRPP - DONE % Something off with roll
        mad = F_GetSOD(mad); % SOD % JRPP - DONE
        mad = F_GetSFWD(mad); % SFD and SWD
        save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    
    % Splitting data into trials - For variables that consider more than one
    % frame or those that can't be computed for all trials
        split_f = @(x) F_SplitTrials(x, mad.TrialLen-1); % JRPP - DONE
        mad.Motor = F_ApplyToStruct(split_f, mad.Motor, ["Yaw", "Pitch", "Roll", ...
            "SOD", "SFD", "SWD", "PC" + string(1:3)], "Annex", false);
        save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    
    % Computing split vars (those that require information about surrounding
    % vars)
        mad = F_GetLocomotion(mad); % Locomotion % JRPP - DONE
        save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    
    % Generating the derivatives
        DerivFunct = @(x) F_Derivate(x);
        mad.Motor = F_ApplyToStruct(DerivFunct, mad.Motor, [], ...
            "Annex", true, "Prefix", "d");
        save(mad.RunParams.SaveLoc + "\mad.mat", "mad")

    %% XGBoosting
    % Binning the data and XGBoosting
        terminate(pyenv)
        [mad, iter] = F_XGBoost(mad, "Constraint", ...
            mad.Neurons.GoodUnits_Phy + mad.Neurons.ROINeurons == 2, ...
            "IterationName", "SC_PCsXGB_V2"); % For models
        terminate(pyenv)
    
    % Generating the tuning curves for each neuron
        try
            [mad] = ...
                F_TuneNeurons(mad, iter, "Full", 2000);
        catch
            warning("Session did not tune")
        end
            
        F_ViewXGB(mad, "Mode", "Talk", "Iteration", iter)
        save(mad.RunParams.SaveLoc + "\mad.mat", "mad")

end

