function [fig] = F_PlotPose(ProjectSettings, Pose, varargin)
%F_PLOTPOSE Summary of this function goes here
%   Detailed explanation goes here

AddArgs = ["xLim", "yLim", "zLim", "LandmarkColour", "LineWidth", ...
    "LandmarkSize", "LandmarkAlpha", "LineColour", "LineAlpha", "Mode"];

ArgValues = F_VararginSelection(AddArgs, ...
    {'matrix', 'matrix', 'matrix', 'matrix', 'double', 'double', ...
    'double', 'matrix', 'double', 'string'}, ...
    {'', '', '', '', '', '', '', '', '', ["Talk", "Default"]}, ...
    {[0, 0], [0, 0], [0, 0], [0, 0], 1.3, 100, 1, [-1, -1, -1], 1, "Default"}, varargin{:});

bkcol = 'w';
axcol = 'k';

if ArgValues{"Mode"} == "Talk"
    if all(ArgValues{"LineColour"} == [-1, -1, -1])
        ArgValues{"LineColour"} = [1, 1, 1];
        bkcol = 'k';
        axcol = 'w';
    end
else
    if all(ArgValues{"LineColour"} == [-1, -1, -1])
        ArgValues{"LineColour"} = [0, 0, 0];
    end
end


% Reading the settings in the project file
Skeleton = ProjectSettings.Visualisations.Skeleton;
Colordata = ProjectSettings.Visualisations.LandmarkColour;

% Changing the landmark color if the user requests it
if size(ArgValues{"LandmarkColour"}, 2) ~= 2
    Colordata = repmat(ArgValues{"LandmarkColour"}, size(Colordata, 1), 1);
else
        % And adjusting for dark figures
    if ArgValues{"Mode"} == "Talk"
        Colordata = Colordata.*1.2 + .1;
        Colordata(Colordata > 1) = 1;

    end
end


hold on
for n_i = 1:size(Skeleton, 1)
    
    plot3(Pose(Skeleton(n_i, :), 1), Pose(Skeleton(n_i, :), 2), ...
        Pose(Skeleton(n_i, :), 3), "LineWidth", ...
        ArgValues{"LineWidth"}, "Color", ...
        [ArgValues{"LineColour"}, ArgValues{"LineAlpha"}]);
   
end
for l_i = 1:size(Pose, 1)
    scatter3(Pose(l_i, 1), Pose(l_i, 2), Pose(l_i, 3), ...
        ArgValues{"LandmarkSize"}, Colordata(l_i, :), 'filled', ...
        "MarkerFaceAlpha", ArgValues{"LandmarkAlpha"});

end
hold off

%% Adding to the visualisation
xlabel('X')
ylabel('Y')
zlabel('Z')

axis equal
hold off
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

% Updating mode
fig = gca;
hold off
fig.FontName = "bahnschrift";
fig.Color = bkcol;          
fig.ZColor = axcol;         fig.XColor = axcol;         fig.YColor = axcol;
if ArgValues{"Mode"} == "Talk"
    fig.FontWeight = 'bold';
end
f = gcf;
f.Color = bkcol;

end