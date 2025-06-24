function [mad] = F_TriangulateObject(mad)
%% Preprocessing
% When the object has been manually labelled (either via DLC or matlab)
if mad.RunParams.ObjectLabel ~= "Auto"
    if mad.RunParams.ObjectLabel == "MATLAB"

        % Params and storage
        n_obland = length(mad.Obj.LandName);
        good_obland = ...
            true(n_obland, mad.NCams, length(mad.Obj.ObjTrials)); % Good lands
        label_in = cell(1, length(mad.Obj.ObjTrials)); % Storage
                label_in(:) = {cell(1, n_obland)};

        % Restructuring the data for triangulation
        for t_ix = 1:length(mad.Obj.ObjTrials)
            for c_ix = 1:mad.NCams
                for land_ix = 1:n_obland

                    % Storing
                    label_in{t_ix}{land_ix}(:, c_ix) = ...
                        flip(mad.Obj.Labels{mad.Obj.ObjTrials(t_ix...
                        )}{c_ix}(land_ix, :).');
                    % Annotating non-labelled landmarks
                    if isnan(label_in{t_ix}{land_ix}(1, c_ix))
                        good_obland(land_ix, c_ix, t_ix) = false;
                    end
                end
            end
        end

% When the object was labelled through DLC
    elseif mad.RunParams.ObjectLabel == "DLC"
        % Geting DLCd object coordinates
        % UI
        [fname, fpath] = uigetfile([char(mad.DayFolder), '\*.csv'], ...
            "Select the object coordinates file.");
    
        % Loading the dataset
        fprintf("Triangulating objects.")
        try % New DLC
            dlc_obj = csvread([fpath, fname], 3,3); %#ok<*CSVRD>
        catch   % Old DLC
            dlc_obj = csvread([fpath, fname], 3,1);
        end
        dlc_obj(dlc_obj == 0) = NaN;
        
        % Determining that there are the correct number of labels
        % if size(dlc_obj, 1) ~= length(mad.Obj.ObjTrials)*mad.NCams
        %     error("Incorrect number of labelled frames. Please make " + ...
        %         "sure that all your frames are correctly labelled.")
        % else
        %     fprintf("    Correct number of labelled frames.")
        % end

    
        % Slicing the data
        all_objs = cell(1, length(mad.Obj.ObjTrials)); % Storage
        for t_ix = 1:length(mad.Obj.ObjTrials) % Trials
            all_objs{t_ix} = cell(1, mad.NCams); % Storage
            t_data = ... % Slicing
                dlc_obj(((t_ix-1)*mad.NCams + 1):(t_ix*mad.NCams), :);
            for c_ix = 1:mad.NCams % Cameras
                all_objs{t_ix}{c_ix} = t_data(c_ix, :); % Storing
            end % Cameras
        end % Trials
    
        % Parms
            n_obland = size(dlc_obj, 2)/2; % Number of object parts
    
        % Data restructuring - Surely this can be done more effectively...
        label_in = cell(1, length(mad.Obj.ObjTrials)); % Storage
            label_in(:) = {cell(1, n_obland)};

        good_obland = ...
            true(n_obland, mad.NCams, length(mad.Obj.ObjTrials)); % Good lands

        for t_ix = 1:length(mad.Obj.ObjTrials) % Trial
            for land_ix = 1:n_obland % Obj Landmark
                for c_ix = 1:mad.NCams % Cam

                    label_in{t_ix}{land_ix}(1,c_ix) = ...
                        all_objs{t_ix}{c_ix}(1,(land_ix*2)); 
                    label_in{t_ix}{land_ix}(2,c_ix) = ...
                        all_objs{t_ix}{c_ix}(1,(land_ix*2-1));

                    % Noting non-labelled instances
                        if isnan(all_objs{t_ix}{c_ix}(1, land_ix*2-1))
                            good_obland(land_ix, c_ix, t_ix) = false;
                        end
                end % Cam
            end % Obj Land
        end % Trial
    end

%% Triangulating the objects
    coordinates_all = cell(1, length(mad.Obj.ObjTrials)); % Output storage
        coordinates_all(:) = {zeros(n_obland, 3)};

    for t_ix = 1:length(mad.Obj.ObjTrials) % Trial
        for land_ix = 1:n_obland % Object part

            ok_cams = find(good_obland(land_ix, :, t_ix)); % Counting ok cameras

            % Triangulating if enough cameras are available
                if length(ok_cams) >= 2
                    x(:, land_ix) = ...
                        F_Triangulate(label_in{t_ix}{land_ix}(:, ok_cams), ...
                        mad.P(ok_cams)); %#ok<AGROW> % Triangulation
                    coordinates_all{t_ix}(land_ix,:) = ...
                        x((1:3),land_ix); % Storage
                else
                    coordinates_all{t_ix}(land_ix, :) = NaN;
                end
        end

        coordinates_all{t_ix} = ...
            reshape(coordinates_all{t_ix}, ...
            [numel(coordinates_all{t_ix})/3,3]);
    end



%% WHEN THE OBJECT IS DLCD - JRPP INTEGRATE IN RUNPARAMS
else % mad.RunParams.ObjectLabel == "Auto"
    % Identifying DLC outputs
    files = string({dir(mad.RunParams.ObjVideos + "\*.csv").name});

    % Sorting all files
    camdata = cell(1, mad.Trials);
    for t_ix = mad.Obj.ObjTrials
        camdata{t_ix} = mad.RunParams.ObjVideos + "\" + ...
            files(~cellfun(@isempty, ...
            regexp(files, ['trial_' num2str(t_ix) 'DLC'],'match')));
    end

    % Storage
    coordinates_all = cell(1, length(mad.Obj.ObjTrials)); % Output storage
    c_ = 1; % For storage

    % Iterating per trial objects
    for t_ix = mad.Obj.ObjTrials

        % Triangulating
        triang_frams = triangulate_DLC(camdata{t_ix}, mad.P, ...
            "Threshold", .2);

        % Extracting frame median
        coordinates_all{c_} = ...
            nanmedian(triang_frams, 3); %#ok<NANMEDIAN>  
            % Using median (opposed to mean) to avoid doing outlier
            % elimination.
        c_ = c_ + 1;
    end
end       


%% Saving
mad.Obj.Triangulated = coordinates_all;
mad.Prog.ObjTrian = datetime("now");

%% ACTUAL TRIANGULATION FUNCTION (RSP)
    function[Xest] = F_Triangulate(x,P)
    % RSP
    % this is the single point LS linear triangulation for an arbitrary
    % number of cameras
    % INPUT: 
    % x: homogeneous 2D coordinates
    % P: camera matrices (array of cells, one cell per camera matrix)
    % OUTPUT: 
    % Xest: 3D estimate in normalized homogeneous coordinates 
     
    Ncam = length(P);
    A = zeros(2*Ncam,4);
    for n = 1:Ncam
        A(2*(n-1)+1,:) = x(1,n)*P{n}(3,:)-P{n}(1,:);
        A(2*n,:) = x(2,n)*P{n}(3,:)-P{n}(2,:);
    end
    [~, ~,V] = svd(A); Xest = V(:,end);
    Xest = Xest/Xest(4);
    end
end

