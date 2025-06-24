function mad = F_GenerateVideoObject(mad)

    % Storage and outputs
        vpath = {};
        mad.RunParams.ObjVideos = mad.RunParams.SaveLoc + "\ObjectVideos";
        mkdir(mad.RunParams.ObjVideos);

    % Identifying relevant files
        files = string({dir(mad.VideoFolder + "\*.avi").name});

    % Organising the CSVs
        for t_ix = 1:mad.Trials
            vpath{t_ix} = mad.VideoFolder + "\" + ...
                files(~cellfun(@isempty, ...
                regexp(files, ['trial_' num2str(t_ix) '_'],'match')));
        end

    % Generating the videos
        % For the user
            wb = waitbar(0, "Generating videos for DLC object processing");
        for t_ix = mad.Obj.ObjTrials
            waitbar(t_ix/mad.Trials)
            for c_ix = 1:mad.NCams
                % Creating output video and loading the frames
                vw = VideoWriter(mad.RunParams.ObjVideos + "\" + ...
                    "camera_" + c_ix + "_trial_" + t_ix + ".avi");
                open(vw)

                % Reading
                vr = VideoReader(vpath{t_ix}(c_ix));

                for f_ix = 1:length(mad.Obj.ObjFrames{t_ix})
                    writeVideo(vw, read(vr, mad.Obj.ObjFrames{t_ix}(f_ix)))
                end
                
                
                close(vw)

            end
        end
        close(wb)

    
end

