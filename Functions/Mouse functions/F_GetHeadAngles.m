% Will compute the head angles
function mad = F_GetHeadAngles(mad)
    % Adapted from generate_head_angles_rsp by RSP
    %% Part 1
    % Estimating which are the snout, right ear and left ears
        s_ix = contains(mad.Mouse.LandName, "Snout", ...
            "IgnoreCase", true);

        if sum(s_ix) ~= 1
            warning("Cannot be certain of which landmark " + ...
                "represents the snout. Select which landmark is the snout.")
            [s_ix, tf] = listdlg('ListString',mad.Mouse.LandName);
            if tf == 1
                s_ix = 1;
            end
        end

        e_ix = contains(mad.Mouse.LandName, "Ear", "IgnoreCase", true);

        if sum(e_ix) ~= 2
            warning("Cannot be certain of which landmarks " + ...
                "represents the ears. Assuming that the " + ...
                "second and third larndmarks represent the " + ...
                "right and left ears respectively")
            re_ix = 2;          le_ix = 3;      
        else

            % Identifying right and left
            re_ix = contains(mad.Mouse.LandName, "Right", ...
                "IgnoreCase", true); 
            re_ix = (e_ix + re_ix) == 2;
            le_ix = contains(mad.Mouse.LandName, "Left", ...
                "IgnoreCase", true);
            le_ix = (e_ix + le_ix) == 2;
        end
    
    %% Part 2
    % Actual extraction of the head poses
    % Adapted from LG + RSP code "generate_head_angles_rsp"
        % Storage
        mad.Motor.Yaw = zeros(1, size(mad.Mouse.Refined, 3));
        mad.Motor.Pitch = mad.Motor.Yaw;    mad.Motor.Roll = mad.Motor.Yaw;
        
        % Defining reference coordinates
        i = [1; 0; 0];
        j = [0; 1; 0];
        k = [0; 0; 1];
        
        R = [i, j, k]; % Allocentric reference
        
        clear i j k
        
        for f_ix = 1:size(mad.Mouse.Refined, 3)
        
            % Egocentric mouse coordinates
            o_m = (mad.Mouse.Refined(re_ix, :, f_ix) + ...
                mad.Mouse.Refined(le_ix, :, f_ix))./2; % Egocentric O
            
            % Yes
            i_m = (mad.Mouse.Refined(s_ix, :, f_ix) - o_m) ./ ...
                norm(mad.Mouse.Refined(s_ix, :, f_ix) - o_m);
            j_m = (mad.Mouse.Refined(le_ix, :, f_ix) - o_m) ./ ...
                norm(mad.Mouse.Refined(le_ix, :, f_ix) - o_m);
            j_m = j_m - (j_m*i_m')*i_m;
            k_m = cross(i_m,j_m);
        
            % Rotating the pose to the allocetric coordinate
            [~, ~, T] = procrustes([i_m', j_m', k_m'], R, ...
                'Scaling', false,'Reflection',false);
            
            % Calculating the pitch
            mad.Motor.Pitch(f_ix) = -real(asind(T.T(3, 1)));
            
            % Computing yaw and pitch given procrustes transform
            % Slabaugh reff.
            if (mad.Motor.Pitch(f_ix)~=90)&&(mad.Motor.Pitch(f_ix)~=-90) 
        
                % Mhm
                mad.Motor.Roll(f_ix) = ...
                    atan2d(T.T(3, 2) / cosd(mad.Motor.Pitch(f_ix)), ...
                    T.T(3, 3) / cosd(mad.Motor.Pitch(f_ix)));
                mad.Motor.Yaw(f_ix) = ...
                    atan2d((T.T(2, 1) / cosd(mad.Motor.Pitch(f_ix))), ...
                    T.T(1, 1) / cosd(mad.Motor.Pitch(f_ix)));
            else
                warning("Apparently abs(pitch) == 90 for frame" + ...
                    num2str(f_ix) + ".")
                mad.Motor.Roll(f_ix) = nan;
                mad.Motor.Yaw(f_ix) = nan;
            end
        end

    %% Part 3 - Optional
    % Histogram visualisation of the head angles
    if mad.RunParams.ViewHeadAngles == true
        F_ViewHeadAngles(mad, "Mode", mad.RunParams.FigMode)
        exportgraphics(gcf, ...
            mad.RunParams.FigSaveLoc + "\HeadAmgles.pdf", ...
            "ContentType", "vector")
    end
    
end