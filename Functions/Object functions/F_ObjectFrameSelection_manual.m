function [mad] = F_ObjectFrameSelection_manual(mad)
%F_OBJECTFRAME Summary of this function goes here

% Instructions
fprintf("Selecting frames for object triangulation. Select" + ...
    " frames where all object landmarks are visible.\n    " + ...
    "A if the frame is good.\n    D if the frame is not good.\n    " + ...
    "Space to go back.\n")


% User input
    folder = uigetdir(mad.DayFolder, ...
        "Select videos folder"); % Determining location
    avis = string(folder) + "\" + string({dir([folder, '\*.avi']).name});

% Storage
    VidFrams.Trial = mad.Obj.ObjTrials;
    VidFrams.Frame = NaN(size(mad.Obj.ObjTrials));


% UI
    end_ = false;
    t = 1;
    f = figure;

    while ~end_
    
        fnum = round(mad.TrialLen*rand(1));
        ViewFrame(mad.Obj.ObjTrials(t), fnum)
    
        w = waitforbuttonpress;
        selection = f.CurrentCharacter;
    
        % Updating accordingly
        if strcmp(selection,'a')
            VidFrams.Frame(t) = fnum;
            t = t+1;
            if t == length(mad.Obj.ObjTrials) + 1
                end_ = true;
            end
        elseif strcmp(selection,'d')
            t = t; %#ok<ASGSL>
        elseif strcmp(selection,' ')
            if t > 1
                t = t-1;
            end    
        end

        
    end
    close all


% Generating the output
    if mad.RunParams.ObjectLabel == "DLC"

        % Creating the output video
            vw = VideoWriter(string(folder) + "\" + ...
                "ObjectFrameSelection.avi");
            open(vw)

        wb = waitbar(0, "Generating video"); % UI

        % Populating video with selected frames
            c_ = 1; % Counter
            for t_ix = VidFrams.Trial % Trial loop

                waitbar(c_/length(VidFrams.Trial)) % UI

                for c_ix = 1:mad.NCams %#ok<*FXUP>
                    vname = avis(contains(...
                        avis, "camera_" + c_ix + "_trial_" + t_ix + "_"));
                    v = VideoReader(vname);
                    writeVideo(vw, read(v, VidFrams.Frame(c_)))
                    
                end
                c_ = c_ + 1;
            end
            
        close(vw)
        close(wb)
    elseif mad.RunParams.ObjectLabel == "MATLAB"
        wb = waitbar(0, "Exporting frames"); % UI

        % Making labelled frame folder
            fname = split(mad.DayFolder, '\');
            fname = fname{end};
            mad.Obj.LabelPath = mad.DayFolder + "\" + ...
                fname + " - Object Labels";
            mkdir(mad.DayFolder + "\" + fname + " - Object Labels")
            mad.Obj.ImagesFolder = mad.DayFolder + "\" + fname;

            c_ = 1; % Counter

        % Exporting video frames
            for t_ix = VidFrams.Trial % Trial loop
    
                waitbar(c_/length(VidFrams.Trial)) % UI
    
                for c_ix = 1:mad.NCams % Camera loop

                    % Finding corresponding frame
                    vname = avis(contains(...
                        avis, "camera_" + c_ix + "_trial_" + t_ix + "_"));
                    v = VideoReader(vname);

                    % Determining the savename for the image
                    svname = "ObjectFrame_Trial_" + t_ix + ...
                        "_Camera_" + c_ix + ".png";

                    % Writing
                    imwrite(read(v, VidFrams.Frame(c_)), ...
                        mad.Obj.ImagesFolder + "\" + svname)

                    
                end
                c_ = c_ + 1;
            end
        close(wb)
    else
        error(mad.RunParams.ObjectLabel + " was not recognised as a " + ...
            "valid method to label the objects. Select either " + ...
            "DLC or MATLAB and run again.")
    end



%% SUPPORTING FUNCTION
    function ViewFrame(t_ix, fnum)
        for c_ix = 1:mad.NCams % Iterating per camera
            % Finding the correct input video
            vname = avis(contains(...
                avis, "camera_" + c_ix + "_trial_" + t_ix + "_"));

            if isempty(vname) % UI
                error("MISSING FILE: No bodycam file has been found " + ...
                    "for camera " + c_ix + " trial " + t_ix + ".")
            end

            % Visualising
                v = VideoReader(vname);
                subplot(2, 2, c_ix)
                image(read(v, fnum))
                sgtitle("Trial " + t_ix)

        end
    end

%% Updating progress
mad.Prog.ObjFram = datetime("now");
mad.Obj.ObjFrames = VidFrams.Frame;

end

