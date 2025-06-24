function [mad] = F_GetSFWD(mad)
close all
% Storage
mad.Motor.SWD = nan(1, size(mad.Mouse.Refined, 3));

% Defining the sigmoid
beta = 2; 
f = @(x) 2./(1+exp(-beta.*x))-.5; 

% Loading the arena
if mad.RunParams.ArenaModel == "Default"
    m = load("arena_model.mat");
else 
    m = load(mad.RunParams.ArenaModel);
end

% Assigning it to mad struct
mad.RunParams.ArenaMesh = m.(string(fieldnames(m)));

% Transposing if required
if size(mad.RunParams.ArenaMesh, 1) == 3
    mad.RunParams.ArenaMesh = mad.RunParams.ArenaMesh.';
end

% Snout coords
snt = permute(mad.Mouse.Refined(mad.Mouse.LandName == "Snout", :, :), ...
    [3, 2, 1]);
mad.Motor.SFD = f(snt(:, 3)).'; % SFD

% Iterating per frame
for f_ix = 1:size(mad.Mouse.Refined, 3)
    mad.Motor.SWD(f_ix) = ...
        f(min(sqrt(sum((mad.RunParams.ArenaMesh-snt(f_ix, :)).^2, 2))));
end


% Visualisation of snout wall distance
    scatter3(snt(:, 1), snt(:, 2), snt(:, 3), 25, mad.Motor.SWD, 'filled')
    colormap(mad.RunParams.Palette)
    cb = colorbar;
    c_lim = cb.Limits;
    axis equal
    hold on
    trisurf(boundary(mad.RunParams.ArenaMesh), ...
        mad.RunParams.ArenaMesh(:, 1), mad.RunParams.ArenaMesh(:, 2), ...
        mad.RunParams.ArenaMesh(:, 3), "FaceColor", [.5, .5, .5], ...
        "FaceAlpha", .3, "LineStyle", "none")
    xlabel("X");     ylabel("Y");     zlabel("Z");
    clim(c_lim);
    title("Snout-Wall Distance")
    hold off
    
    f = gcf;
    f = F_FigureMode(f, mad, cb);
    saveas(f, mad.RunParams.FigSaveLoc + "\SWD")

% Visualisation of snout-floor distance
    close all
    scatter3(snt(:, 1), snt(:, 2), snt(:, 3), 25, mad.Motor.SFD, 'filled')
    colormap(mad.RunParams.Palette)
    cb = colorbar;
    c_lim = cb.Limits;
    axis equal
    hold on
    xlabel("X");     ylabel("Y");     zlabel("Z");
    clim(c_lim);
    title("Snout-Floor Distance")
    hold off
    
    f = gcf;
    f = F_FigureMode(f, mad, cb);
    saveas(f, mad.RunParams.FigSaveLoc + "\SFD")
    close all

end

