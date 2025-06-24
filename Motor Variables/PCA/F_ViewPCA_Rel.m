function F_ViewPCA_Rel(mad)


Output = mad.RunParams.FigSaveLoc + "\PCRel.pdf";

if mad.RunParams.FigMode == "Talk"
    col = "w";
    bcol = 'k';
else
    col = "k";
    bcol = "w";
end


if mad.SupMotor.PC_NComps > 6
    mad.SupMotor.PC_NComps = 6
end

% Defining the shape of the output figure
image_ix = reshape(1:(mad.SupMotor.PC_NComps).^2, mad.SupMotor.PC_NComps, []).';

% Defining all permutations
pms = perms(1:mad.SupMotor.PC_NComps);
pms(:, 3:end) = [];
pms = cat(1, unique(pms, "rows"), (ones(2, mad.SupMotor.PC_NComps).*(1:mad.SupMotor.PC_NComps)).');
pms(pms(:, 1) < pms(:, 2), :) = [];
%% Scatter visualisation
for p_ix = 1:size(pms, 1) % Iterating per parameter
    subplot(mad.SupMotor.PC_NComps, mad.SupMotor.PC_NComps, ...
        image_ix(pms(p_ix, 1), pms(p_ix, 2)))
    scatter(mad.SupMotor.PCA(:, pms(p_ix, 2)), ...
        mad.SupMotor.PCA(:, pms(p_ix, 1)), col, ...
        "filled", "MarkerFaceAlpha", .2)

    % Labels
    if pms(p_ix, 2) == 1
        ylabel(pms(p_ix, 1))
    end

    if pms(p_ix, 1) == mad.SupMotor.PC_NComps
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

exportgraphics(gcf, Output, "Append", false, "ContentType", "image")

%% Generating the probability distributions
for p_ix = 1:size(pms, 1)
    subplot(mad.SupMotor.PC_NComps, mad.SupMotor.PC_NComps, ...
        image_ix(pms(p_ix, 1), pms(p_ix, 2)))

    % Determining the sigma using pairwise distance
    a = [mad.SupMotor.PCA(:, pms(p_ix, 2)), mad.SupMotor.PCA(:, pms(p_ix, 1))];
    sig = median(pdist(gpuArray(a(1:2:end, :))))/2;
    F_GaussianConvolveScatter(...
        [mad.SupMotor.PCA(:, pms(p_ix, 2)), mad.SupMotor.PCA(:, pms(p_ix, 1))], ...
        sig, "NBins", 20, "Mode", mad.RunParams.FigMode);

    % Labels
    if pms(p_ix, 2) == 1
        ylabel(pms(p_ix, 1))
    end
    if pms(p_ix, 1) == mad.SupMotor.PC_NComps
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

exportgraphics(gcf, Output, "Append", true, "ContentType", "vector")

end

