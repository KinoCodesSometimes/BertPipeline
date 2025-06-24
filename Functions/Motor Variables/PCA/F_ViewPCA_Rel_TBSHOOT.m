NComps = 4;
d = rand(100, NComps)
mode = "Talk";
Output = "PCRel.pdf"


if mode == "Talk"
    col = "w";
    bcol = 'k';
else
    col = "k";
    bcol = "w";
end

% Defining the shape of the output figure
image_ix = reshape(1:(NComps).^2, NComps, []).';

% Defining all permutations
pms = perms(1:NComps);
pms(:, 3:end) = [];
pms = cat(1, unique(pms, "rows"), (ones(2, NComps).*(1:NComps)).');
pms(pms(:, 1) < pms(:, 2), :) = [];

%% Scatter visualisation
for p_ix = 1:size(pms, 1) % Iterating per parameter
    subplot(NComps, NComps, image_ix(pms(p_ix, 1), pms(p_ix, 2)))
    scatter(d(:, pms(p_ix, 1)), d(:, pms(p_ix, 2)), col, ...
        "filled", "MarkerFaceAlpha", .2)

    % Labels
    if pms(p_ix, 2) == 1
        ylabel(pms(p_ix, 1))
    end

    if pms(p_ix, 1) == NComps
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

exportgraphics(gcf, Output, "Append", false, "ContentType", "vector")

%% Generating the probability distributions
for p_ix = 1:size(pms, 1)
    subplot(NComps, NComps, image_ix(pms(p_ix, 1), pms(p_ix, 2)))

    % Determining the sigma using pairwise distance
    dist = pdist([d(:, pms(p_ix, 1)), d(:, pms(p_ix, 2))]);
    sig = .05.*median(dist);
    F_GaussianConvolveScatter([d(:, pms(p_ix, 1)), d(:, pms(p_ix, 2))], ...
        sig, "NBins", 100, "Mode", mode);

    % Labels
    if pms(p_ix, 2) == 1
        ylabel(pms(p_ix, 1))
    end
    if pms(p_ix, 1) == NComps
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
