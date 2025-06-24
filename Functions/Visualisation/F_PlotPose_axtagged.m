function [ax] = F_PlotPose_axtagged(ax, ProjectSettings, Pose, varargin)
%F_PLOTPOSE Summary of this function goes here
%   Detailed explanation goes here

AddArgs = ["xLim", "yLim", "zLim", "LandmarkColour", "LineWidth", ...
    "Angle", "LandmarkSize", "LandmarkAlpha", "ViewSkeleton", ...
    "SkeletonColour", "IgnoreLandmarks"];

ArgValues = F_VararginSelection(AddArgs, ...
    {'matrix', 'matrix', 'matrix', 'matrix', 'double', 'matrix',...
    'double', 'double', 'logical', 'matrix', ["matrix", "double"]}, ...
    {'', '', '', '', '', '', '', '', '', '', ''}, ...
    {[0, 0], [0, 0], [0, 0], [0, 0], 1.3, [45, 45], 100, 1, true, ...
    [0, 0, 0], [0]}, varargin{:});


% Reading the settings in the project file
Skeleton = ProjectSettings.Visualisations.Skeleton;
Colordata = ProjectSettings.Visualisations.LandmarkColour;
Exclude = zeros(length(Skeleton), 1);
if ~isempty(ArgValues{"IgnoreLandmarks"}) 
    for land_ix = 1:length(ArgValues{"IgnoreLandmarks"})
        land = ArgValues{"IgnoreLandmarks"}(land_ix);
        Exclude(sum(Skeleton == land, 2) ~= 0) = 1;
    end
end


% Changing the landmark color if the user requests it
if size(ArgValues{"LandmarkColour"}, 2) ~= 2
    Colordata = repmat(ArgValues{"LandmarkColour"}, size(Colordata, 1), 1);
end

if ArgValues{"ViewSkeleton"}
    for n_i = 1:size(Skeleton, 1)
        if Exclude(n_i) == 0
            hold(ax, "on")
            plot3(ax,Pose(Skeleton(n_i, :), 1), Pose(Skeleton(n_i, :), 2), ...
                Pose(Skeleton(n_i, :), 3), "LineWidth", ...
                ArgValues{"LineWidth"}, "Color", ...
                ArgValues{"SkeletonColour"});
        end
       
    end
else
    hold(ax, "on")
end

for l_i = 1:size(Pose, 1)

    if sum(ArgValues{"IgnoreLandmarks"} == l_i) == 0
        scatter3(ax,Pose(l_i, 1), Pose(l_i, 2), Pose(l_i, 3), ...
            ArgValues{"LandmarkSize"}, ...
            Colordata(l_i, :), 'filled', "MarkerFaceAlpha", ...
            ArgValues{"LandmarkAlpha"});
    end

end


%% Adding to the visualisation
xlabel(ax,'X')
ylabel(ax,'Y')
zlabel(ax,'Z')

axis(ax, "equal")

% Setting the limits be that needed
if ~ArgValues{"xLim"} == [0, 0]
    xlim(ArgValues{"xLim"})
end

if ~ArgValues{"yLim"} == [0, 0]
    ylim(ArgValues{"yLim"})
end

if ~ArgValues{"zLim"} == [0, 0]
    zlim(ArgValues{"zLim"})
end
view(ax, ArgValues{"Angle"}(1), ArgValues{"Angle"}(2))
set(gcf,'Position',[179, 139, 1040, 800])

end