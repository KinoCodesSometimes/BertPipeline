function [mad] = F_ObjectFrameSelection_auto(mad)
%F_GETOBJFRAMES Summary of this function goes here
%   Detailed explanation goes here

% Determining the distance
sod2d = sum((permute(mad.Mouse.Refined(1, [1, 2], :), [3, 2, 1])...
    - mad.Obj.EstimCoords).^2, 2);

% Storage
mad.Obj.ObjFrames = cell(1, mad.Trials);

% Segmenting trials
for t_ix = mad.Obj.ObjTrials
    % Finding trial frames
    t_sod2d = sod2d(((t_ix-1)*(mad.TrialLen-1)+1):(t_ix*(mad.TrialLen-1)));

    % CDF
    [f, x] = ecdf(t_sod2d);

    % Constraining to 20% most distant frames for given trial
    distframs = find(t_sod2d > x(find(f>0.8, 1)));

    % Randomising and selecting frames
    rf = distframs(randperm(length(distframs)));
    mad.Obj.ObjFrames{t_ix} = rf(1:400);
end


end

