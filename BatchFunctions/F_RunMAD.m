function F_RunMAD(TrialLen, Trials, NCams, ...
    BinWudth, FPS, ObjTrials, ObjLandName, ObjEstimCoords, ...
    MouseLandName, LoadNidaq, Moth, Bod, DLCconf, PMat, Eph)
    % Global Project Parms
        mad.TrialLen = TrialLen; % Number of frames per trial
        mad.Trials = Trials; % Number of trials
        mad.NCams = NCams; % Number of cameras
        mad.DayFolder = Moth; % Day folder
        mad.VideoFolder = Bod; % Path containing bodycam videos
        mad.DLCFolder = ""; % Folder containing DLC output (if empty, script will DLC for you)
        mad.DLCNet = DLCconf; % Path to config file for the desired DLC network
        mad.PPath = PMat; % P matrix path
        mad.BinWidth = BinWudth; % In frames.
        mad.FPS = FPS; % Recording frequency for bodycam
    
    % About the object
        mad.Obj.ObjTrials = ObjTrials; % Trials containing an object
        mad.Obj.LandName = ObjLandName; % Obj landmark names
        mad.Obj.EstimCoords = ObjEstimCoords;
        mad.Obj.ObjDLCNet = ...
            "Y:\Joaquin\DLC - Networks\StandardObjects-JRPP-2024-11-11\config.yaml";
    
    % About the mouse
        mad.Mouse.LandName = MouseLandName; % Mouse landmark name
    
    
    % About Ephys
        mad.Ephys.EphysFolder = Eph;
            % Location of ephys recordings (no need to concatenate/kilosort)
        mad.RunParams.LoadNidaq = LoadNidaq;
    
    
    % Other parameters
        mad.RunParams.PlotFigs = NaN; % or true/false % JRPP - Include for each figure
            % if NaN, will only plot figures specified in mad.RunParams.
            % if true, all figures will be plotted. mad.RunParams will be
            % ignored
            % if false, no figures will be plotted.
    
    
    addpath(genpath(pwd))
    Initiate_mad
    
    mad.RunParams.ExcludeImplant = true;
    
    %% Deeplabcutting
    
    mad = F_DLC(mad); % JRPP - DONE
    
    terminate(pyenv)
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    %% Ephys Processing
    % Concatenation - Adapted
    if islogical(mad.Prog.Cat) % JRPP - DONE
        [mad.Ephys.CatFolders, ~, mad.Ephys.ChanMap] = ...
            F_KiloConcatenate(mad.Ephys.EphysFolder); % Concatenating
        mad.Prog.Cat = datetime("now"); % Saving the paths
        mad.Ephys.Concatenated = mad.Ephys.EphysFolder + "\Concatenated.dat";
    end
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    
    terminate(pyenv) % Terminating previous python environments
    
    % Kilosorting - Using Kilosort4
    if islogical(mad.Prog.Kilo) % JRPP - DONE
        F_CallKilosort(mad) % JRPP - NOTE: Make conda environment paths pc-variant - See Get Computer Name on Acute Processing Pipeline
        mad = F_DeconcatEphys(mad); % Processing kilosorted data
        mad = F_BinUnits(mad);
        mad.Prog.Kilo = datetime("now");
    end
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    
    
    % Manual neuronal curation - Manual/Kilosort/Bombcell
    % See mad.RunParams.Curation (Initiate_mad)
    if islogical(mad.Prog.Curation)
        mad = F_CurateNeurons(mad); % JRPP - Sort out Bombshell from the acutes
        mad.Prog.Curation = datetime("now");
    end
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    terminate(pyenv)
    
    %% Mouse triangulation
    mad = F_Triangulation(mad); % JRPP - DONE 
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
            
    %% Object processing
    if islogical(mad.Prog.ObjTrian)
        mad = F_ProcessObject(mad); % JRPP - Done
    end
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    terminate(pyenv)
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
    
    % Computing split vars
    mad = F_GetLocomotion(mad); % Locomotion % JRPP - DONE
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    
    % Generating the derivatives
    DerivFunct = @(x) F_Derivate(x);
    mad.Motor = F_ApplyToStruct(DerivFunct, mad.Motor, [], ...
        "Annex", true, "Prefix", "d");
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    %% XGBoosting
    
    % Binning the data - JRPP - Complete
    mad = F_XGBoost(mad);
    terminate(pyenv)
    F_ViewXGB(mad, "Mode", "Talk")
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    fprintf("\n Data was saved ok.")
end

