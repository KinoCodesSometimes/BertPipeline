function [n_Components] = F_Scree(VarianceExplained, TargetVariance, ...
    varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
close all
ArgValues = F_VararginSelection(["Orientation", "Mode"], ...
    {'string', 'string'}, ...
    {["Horizontal", "Vertical"], ["Talk", "Default"]}, ...
    {"Vertical", "Default"}, varargin{:});

cumsum(VarianceExplained)

% Identifying number of components needed to explain the target variance
n_Components = find(cumsum(VarianceExplained) > TargetVariance, 1);

if ArgValues{"Mode"} == "Talk"
    col = "w";
    lcol = "k";
    lw = 2;
elseif ArgValues{"Mode"} == "Default"
    col = "k";
    lcol = "w";
    lw = 1.2;
end

       

% Plotting the variance explained by all components
% And the cumulative distribution plots
if ArgValues{"Orientation"} == "Horizontal"
    barh(VarianceExplained, col, "FaceColor", "flat");
    hold on
    plot(cumsum(VarianceExplained), 1:length(VarianceExplained), ...
        "Color", col, "LineWidth", lw)
    % Plotting the target and the associated numbers of components
    xline(TargetVariance, "LineWidth", lw, "Color", 'r', 'LineStyle', ":")
    yline(n_Components, "LineWidth", lw, "Color", 'r', 'LineStyle', ":")

    % Plotting the components that are needed
    barh(VarianceExplained(1:n_Components), "FaceColor", 'r')

    % Finalising graph
    ylabel("PC")
    xlabel("% of \sigma^2 explained")

    xlim([0, 100])

else
    bar(VarianceExplained, col, "FaceColor", "flat");
    hold on
    plot(cumsum(VarianceExplained), "Color", col, "LineWidth", lw)
    

    % Plotting the target and the associated numbers of components
    yline(TargetVariance, "LineWidth", lw, "Color", 'r', 'LineStyle', ":")
    xline(n_Components, "LineWidth", lw, "Color", 'r', 'LineStyle', ":")

    % Plotting the components that are needed
    bar(VarianceExplained(1:n_Components), "FaceColor", 'r')

    % Finalising graph
    xlabel("PC")
    ylabel("% of \sigma^2 explained")

    ylim([0, 100])
end

f = gca;
l = legend(f, ["\sigma^2 explained", "Cumulative \sigma^2 explained", '', '', ...
    strcat("PCs explaining ", num2str(TargetVariance), "% of \sigma^2")], ...
    "Location","northeast");

if ArgValues{"Mode"} == "Talk"
    f.Color = 'k';
    f.YColor = 'w';
    f.XColor = 'w';
    f.FontWeight = 'bold';
    f.LineWidth = 1.2;
    f.FontSize = 15;
    l.TextColor = col;
    l.Color = lcol;
    l.FontName = "bahnschrift";

    g = gcf;
    g.Color = 'k';
end

f.FontName = "bahnschrift";

box off
end