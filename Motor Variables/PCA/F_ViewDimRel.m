function F_ViewDimRel(XY, varargin)

% Loading the optional visualisation arguments
ArgValues = F_VararginSelection(["Output", "Mode"], ...
    {["string", "logical"], 'string'}, ...
    {'', ["Talk", "Default"]}, ...
    {false, "Default"}, varargin{:});

% Setting visualisation parameters be it needed
if ArgValues{"Mode"} == "Talk"
    col = "w";
    bcol = 'k';
else
    col = "k";
    bcol = "w";
end

% Constraining the number of components that can be visualised
ncomps = min([size(XY, 2), 6]);

% Defining the shape of the output figure
image_ix = reshape(1:(ncomps).^2, ncomps, []).';

% Defining all permutations
pms = perms(1:ncomps);
pms(:, 3:end) = [];
pms = cat(1, unique(pms, "rows"), (ones(2, ncomps).*(1:ncomps)).');
pms(pms(:, 1) < pms(:, 2), :) = [];
%% Scatter visualisation
for p_ix = 1:size(pms, 1) % Iterating per parameter
    subplot(ncomps, ncomps, ...
        image_ix(pms(p_ix, 1), pms(p_ix, 2)))
    scatter(XY(:, pms(p_ix, 2)), ...
        XY(:, pms(p_ix, 1)), col, ...
        "filled", "MarkerFaceAlpha", .2)

    % Labels
    if pms(p_ix, 2) == 1
        ylabel(pms(p_ix, 1))
    end

    if pms(p_ix, 1) == ncomps
        xlabel(pms(p_ix, 2))
    end

    % Theme
    f = gca;
    f.Color = bcol;
    f.YColor = col;
    f.XColor = col;
    f.FontWeight = 'bold';
    f.LineWidth = 1.2;
    f.FontSize = 15;
    f.FontName = "bahnschrift";
end

% Finalising the figure
f = gcf;
f.Position = [680, 20, 900, 900];
f.Color = bcol;

if ~islogical(ArgValues{"Output"})
    exportgraphics(gcf, ArgValues{"Output"} + ".pdf", ...
        "Append", false, "ContentType", "image")

%% Generating the probability distributions
for p_ix = 1:size(pms, 1)
    subplot(ncomps, ncomps, ...
        image_ix(pms(p_ix, 1), pms(p_ix, 2)))

    % Determining the sigma using pairwise distance
    a = [XY(:, pms(p_ix, 2)), XY(:, pms(p_ix, 1))];
    sig = median(pdist(gpuArray(a(1:2:end, :))))/2;
    F_GaussianConvolveScatter(...
        [XY(:, pms(p_ix, 2)), XY(:, pms(p_ix, 1))], ...
        sig, "NBins", 20, "Mode", ArgValues{"Mode"});

    % Labels
    if pms(p_ix, 2) == 1
        ylabel(pms(p_ix, 1))
    end
    if pms(p_ix, 1) == ncomps
        xlabel(pms(p_ix, 2))
    end

    % Theme
    f = gca;
    f.Color = bcol;
    f.YColor = col;
    f.XColor = col;
    f.FontWeight = 'bold';
    f.LineWidth = 1.2;
    f.FontSize = 15;
    f.FontName = "bahnschrift";
    box off

end
% Finalising the figure
f = gcf;
f.Position = [680, 20, 900, 900];
f.Color = bcol;

% Finalising the figure
f = gcf;
f.Position = [680, 20, 900, 900];
f.Color = bcol;

exportgraphics(gcf, Output, "Append", true, "ContentType", "vector")
end