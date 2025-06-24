function [mad] = F_ExcludeLandmarks(mad, varargin)
%% F_ExcludeLandmarks
% JRPP - Nov 2024
% Given a pattern, it will exclude all non-relevant landmarks and update
% the mouse skeleton for the visualisation.]
% INS
%       mad (struct) - Storage struct for the current analyses.
%       OPTIONAL - Pattern - String pattern flagging landmarks to exclude.
% Saving original parameters
mad.Mouse.OgLandName = mad.Mouse.LandName;
mad.RunParams.MouseVis.Visualisations.OgSkeleton = ...
    mad.RunParams.MouseVis.Visualisations.Skeleton;
mad.Mouse.OgRefined = mad.Mouse.Refined;

skel_corr = mad.RunParams.MouseVis.Visualisations.Skeleton;
mad.RunParams.ExcludedLandmarks = []; % Stores

%% Identifying landmarks to exclude
if nargin == 2 % If a pattern was specified
    contains(mad.Mouse.OgLandName, varargin{1})
    [~, mad.RunParams.ExcludedLandmarks] = ...
        find(contains(mad.Mouse.OgLandName, varargin{1}) == 1); % Finding lands to exclude
    if isempty(mad.RunParams.ExcludedLandmarks) % If no landmarks match the pattern
        mad.RunParams.ExcludedLandmarks = ...
            listdlg('ListString',mad.Mouse.LandName, ...
            "PromptString", "Select landmarks to exclude."); % UI
    end

else
    mad.RunParams.ExcludedLandmarks = ...
            listdlg('ListString',mad.Mouse.LandName, ...
            "PromptString", "Select landmarks to exclude."); % UI
end

%% Excluding non-relevant landmarks
    mad.Mouse.LandName(mad.RunParams.ExcludedLandmarks) = []; % From landmark name list
    mad.Mouse.Refined(mad.RunParams.ExcludedLandmarks, :, :) = [];

%% Updating the skeleton
    % Excluding lines connecting the excluded landmarks
    c = 0;
    for ex_l_ix = mad.RunParams.ExcludedLandmarks
        skel_corr = skel_corr(sum(skel_corr == (ex_l_ix-c), 2) == 0, :);
        skel_corr(skel_corr > (ex_l_ix-c)) = ...
            skel_corr(skel_corr > (ex_l_ix - c)) - 1;
        c = c + 1;
    end

    mad.RunParams.MouseVis.Visualisations.Skeleton = skel_corr;

end