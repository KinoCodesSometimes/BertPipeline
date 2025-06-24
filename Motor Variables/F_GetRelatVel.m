function mad = F_GetRelatVel(mad)

% Loading frame used for alignment and prepping storage vars
    load(mad.RunParams.ReferenceMouse)
    mad.Mouse.RelVelocity = cell(1, mad.Trials);

% Splitting the trials
    % Storage
    mad.Mouse.RefinedSplit = cell(1, mad.Trials);

    % Splitting
    for t_ix = 1:mad.Trials
        mad.Mouse.RefinedSplit{t_ix} = ...
            mad.Mouse.Refined(:, :, ...
            ((t_ix-1).*(mad.TrialLen-1) + 1):(t_ix*(mad.TrialLen-1)));
    end


% Aligning
    for t_ix = 1:mad.Trials % Trial
        mad.Mouse.RelVelocity{t_ix} = ...
            zeros(length(mad.Mouse.LandName), 3, mad.TrialLen-1);
        for f_ix = 1:(mad.TrialLen-2) % Frame
            [~, Z, RotTrans_xy] = procrustes(ReferencePose(:, 1:2), ...
                mad.Mouse.RefinedSplit{t_ix}(:, 1:2, f_ix), ...
                "scaling", false, "reflection", false);
            mad.Mouse.RelVelocity{t_ix}(:, :, f_ix) = ...
                [(mad.Mouse.Triangulated(:, 1:2, f_ix + 1)*RotTrans_xy.T + ...
                RotTrans_xy.c) - Z, ...
                mad.Mouse.Triangulated(:, 3, f_ix)];
        end
    end

end

