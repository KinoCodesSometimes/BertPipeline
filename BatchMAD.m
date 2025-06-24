%% EDIT HERE - EXPERIMENT PARAMETERS
    % Note, only days where all of the parameters are the same can be run
    % using the batch script.

% Global Project Parms
    TrialLen = 10800; % Number of frames per trial
    NCams = 4; % Number of cameras
    BinWidth = 15; % In frames for XGB.
    FPS = 30; % Recording frequency for bodycam

% About the object
     % Trials containing an object
    ObjLandName = ["T1", "T2", "T3", "T4", "T5", "T6", ...
        "M1", "M2", ...
        "B1", "B2", "B3", "B4", "B5", "B6"]; % Obj landmark names
    ObjEstimCoords = [0, 0]; % Expected location of the object

% About the mouse
    MouseLandName = ["Snout", "Left Ear", "Right Ear", ...
        "Left Implant", "Right Implant", "Implant Cable", "Neck Base", ...
        "Body Midpoint", "Tail Base", "Neck-Mid", "Body-Tail"]; % Mouse landmark name

% About Ephys
    LoadNidaq = false;

% Loading user input - Change to variable later on
paths = readtable('SampleBatchIn.xlsx', 'VariableNamingRule', 'preserve');

%% Irterating per session
for s_ix = 1:size(paths, 1)
    terminate(pyenv)
    try % Just in case something is fucked
        % Reading the batch file
            Eph = string(paths.("Ephys"){s_ix});
            Bod = string(paths.("Behaviour"){s_ix});
            Moth = string(paths.("Day Session"){s_ix});
            PMat = string(paths.("Ppath"){s_ix});
            DLCconf = string(paths.("DLC Net"){s_ix});
            Trials = paths.("Trials")(s_ix);
            

            ObjTrials = 2:Trials;
            
    
        % Performing all analyses
        F_RunMAD(TrialLen, Trials, NCams, ...
            BinWidth, FPS, ObjTrials, ObjLandName, ObjEstimCoords, ...
            MouseLandName, LoadNidaq, Moth, Bod, DLCconf, PMat, Eph)
        terminate(pyenv)
    catch ME
        warning("FAILED SESSION: " + Moth);
        fprintf(ME.message)
        terminate(pyenv)
    end
end