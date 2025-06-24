function [mad] = prep_3D(mad)
%this function asks for number of frames and then deletes the last frame
%from each trial
trial_n = mad.Trials;
[~,~,n_frames] = size(mad.Triang.Concat);

mad.Mouse.Triangulated = mad.Triang.Concat;
mad.Mouse.Sigma = mad.Triang.SigmaMap;
idx = n_frames/trial_n:n_frames/trial_n:n_frames
mad.Mouse.Triangulated(:,:,idx) = [];
mad.Mouse.Sigma(:,idx) = [];
end