% Global Project Parms
    mad.TrialLen = 10800; % Number of frames per trial
    mad.Trials = 12; % Number of trials
    mad.NCams = 4; % Number of cameras
    mad.DayFolder = "Y:\UG-masters students\2024\Dylan Lowe\cASC1\AUD1 - caSC1"; % Day folder
    mad.VideoFolder = "Y:\Joaquin\Chronics\cSC5\Bert Behaviour\BAD3 - cSC5_NC (v)\AUD1 - caSC1 - Behaviour"; % Path containing bodycam videos
    mad.DLCFolder = "Y:\Joaquin\Chronics\cSC5\Bert Behaviour\BAD3 - cSC5_NC (v)\AUD1 - caSC1 - Behaviour"; % Folder containing DLC output (if empty, script will DLC for you)
    mad.DLCNet = ""; % Path to config file for the desired DLC network
    mad.PPath = "Z:\Bodycam calibrations\calibration 2024 02 15\Pcal_rp.mat"; % P matrix path
    mad.BinWidth = 15; % In frames.
    mad.FPS = 30; % Recording frequency for bodycam

% About the object
    mad.Obj.ObjTrials = NaN; % Trials containing an object
    mad.Obj.LandName = NaN; % Obj landmark names
    mad.Obj.EstimCoords = NaN;
    mad.Obj.ObjDLCNet = ...
        "Y:\Joaquin\DLC - Networks\StandardObjects-JRPP-2024-11-11\config.yaml";

% About the mouse
    mad.Mouse.LandName = ["snout", "left ear left base", ...
        "left ear right base", "left ear tip", "right ear left base", ...
        "right ear right base", "right ear tip", "neck base", ...
        "left elbow", "right elbow", "spine midpoint", "tail base", ...
        "left front paw", "right front paw"]; % Mouse landmark name


% About Ephys
    mad.Ephys.EphysFolder = "Y:\UG-masters students\2024\Dylan Lowe\cASC1\AUD1 - caSC1\AUD1 - caSC1 - Ephys";
        % Location of ephys recordings (no need to concatenate/kilosort)


% Other parameters
    mad.RunParams.PlotFigs = NaN; % or true/false % JRPP - Include for each figure
        % if NaN, will only plot figures specified in mad.RunParams.
        % if true, all figures will be plotted. mad.RunParams will be
        % ignored
        % if false, no figures will be plotted.
 

addpath(genpath(pwd))
Initiate_mad