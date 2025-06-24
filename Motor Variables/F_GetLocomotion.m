function [mad] = F_GetLocomotion(mad)
%% From RSP/LG function vec_decompose
%% Setting arbitrary reference pose
pose = [%4   0     0; %snout
        3  0.5   0; %L ear
        3   -0.5   0; %R ear
        2   0     0; %neck base
       -0   0     0; %mid body
       %-2   0     0; %tail end
        1   0     0; % mid1
       -1   0     0; %mid 2
        ];
    % JRPP - This arbitrary reference may pose plasticity issues, with the
    % pipeline not running smoothly if the used landmarks are not the same
    % as those used for the BC paper.

    % Assuming the only landmarks we need to exclude are the tail base and
    % the snout:
        include_ix = setdiff(1:length(mad.Mouse.LandName), find( ...
            contains(mad.Mouse.LandName, "Snout", "IgnoreCase", true) + ...
            contains(mad.Mouse.LandName, "Tail Base", "IgnoreCase", true) == 1)); % JRPP - Get some clarity on why these are also being excluded

        
%% PREP
    % Requires splitting the data into trials
    mad.Mouse.Refined_Split = ...
        zeros(size(mad.Mouse.Refined, 1), size(mad.Mouse.Refined, 2), ...
        mad.TrialLen-1, size(mad.Mouse.Refined, 3)./(mad.TrialLen-1));
    
    
    % Splitting
    for t_ix = 1:size(mad.Mouse.Refined_Split, 4)
        mad.Mouse.Refined_Split(:, :, :, t_ix) = ...
            mad.Mouse.Refined(:, :, ...
            (((t_ix-1)*(mad.TrialLen-1)+1):(t_ix)*(mad.TrialLen-1)));
    end

        % JRPP - This section silenced due to change to the reference
        % pose.
        % Consider including once a means to making the code somewhat more
        % adaptable to other landmarks...
        % Loading the reference pose
            % a = load(mad.RunParams.ReferenceMouse);
            % f = fieldnames(a); % For plasticity
            % f = f{1};
            % Ref = a.(f);
            % clear a f
            % 
            % % Distinguishing implant landmarks to exclude it from the analyses
            % if mad.RunParams.ExcludeImplant
            %     Ref(mad.RunParams.ExcludedLandmarks, :) = [];
            % end

    % Storage
    mad.Motor.VelX = cell(1, size(mad.Mouse.Refined_Split, 4)); % Create
    mad.Motor.Loco = mad.Motor.VelX;
    mad.Motor.VelX(:) = {zeros(1, mad.TrialLen-1)}; % Populate
    mad.Motor.VelY = mad.Motor.VelX; % Copy
    mad.Motor.VelZ = mad.Motor.VelX;
    



%% Calculating vel
for t_ix = 1:size(mad.Mouse.Refined_Split, 4)
    for f_ix = 1:(mad.TrialLen-2)
        
        % Aligning individual poses to the reference
        [~, Z, T] = procrustes(pose, ...
            mad.Mouse.Refined_Split(include_ix, :, f_ix, t_ix), ...
            "scaling", false, "reflection", false);
    
        % Transforming the next pose
        nxt = mad.Mouse.Refined_Split(include_ix, :, f_ix + 1, t_ix)*T.T + T.c;
    
        % Computing the movement of the centroid and storage
        VelXYZ = mean(nxt, 1) - mean(Z, 1);
            mad.Motor.VelX{t_ix}(f_ix) = VelXYZ(1);
            mad.Motor.VelY{t_ix}(f_ix) = VelXYZ(2);       
            mad.Motor.VelZ{t_ix}(f_ix) = VelXYZ(3);
    end
    
    % Global locomotion
    mad.Motor.Loco{t_ix} = sqrt(sum([mad.Motor.VelX{t_ix}; ...
        mad.Motor.VelY{t_ix}; ...
        mad.Motor.VelZ{t_ix}].^2, 2));
end


end

