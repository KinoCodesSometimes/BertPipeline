function F_MotVarCov(mad)
%% Generates histograms for every motor variable and calculates the covariance between motor variables.
% Used to determine whether a session is good/bad and to determine which
% sessions to chose for further analyses.
%% Generating the visualisations.
load("Rusco.mat", "Rusco")
% Defining the variables
    vars = string(fieldnames(mad.Motor));
    vars(vars == "Loco" | vars == "dLoco") = [];
% Storage
    motor = zeros(length(mad.Obj.ObjTrials).*(mad.TrialLen-1), ...
        length(vars));

% Generating single variable histogram and collecting the motor data
for v_ix = 1:length(vars)

    % Storing the motor data
        motor(:, v_ix) = cat(2, mad.Motor.(vars(v_ix)){mad.Obj.ObjTrials});

    % Single variable histogram
        histogram(motor(:, v_ix), "Normalization", "percentage", ...
            "FaceAlpha", 1, "FaceColor", 'k');

    % Completing the visualisation
        box off
        xlabel(vars(v_ix))
        ylabel("% of frames")
        set(gca, 'FontName', 'Bahnschrift')
        

    % Saving
    if v_ix == 1
        exportgraphics(gcf, ...
            mad.RunParams.FigSaveLoc + "\MotorVarHist.pdf", ...
            "ContentType", "vector", "Append", false)
    else
        exportgraphics(gcf, ...
            mad.RunParams.FigSaveLoc + "\MotorVarHist.pdf", ...
            "ContentType", "vector", "Append", true)
    end
        pause(3)

    
end

%% Correlating the different variables to identify aberrant sessions.

% Transparency for the visualisation
    alphadata = ones(length(vars));
    alphadata = 1-triu(alphadata, 1);

mad.SupMotor.Cov.Cov = corr(zscore(motor, [], 1), 'Rows', 'pairwise');
mad.SupMotor.Cov.Vars = vars;
% Computing the motor variable covariance
    imagesc(mad.SupMotor.Cov.Cov, "AlphaData", alphadata)

% Beautifying
    colorbar
    clim manual
    clim([-1, 1])
    box off
    axis equal
    xlim([.5, length(vars)+.5])
    ylim([.5, length(vars)+.5])
    xticks(1:length(vars))
    yticks(1:length(vars))
    xticklabels(vars)
    yticklabels(vars)
    set(gca, 'FontName', 'Bahnschrift')
    colormap(Rusco)


% Saving
exportgraphics(gcf, ...
    mad.RunParams.FigSaveLoc + "\MotorVarHist.pdf", ...
    "ContentType", "vector", "Append", true)

%% Updating MAD
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    clear mad
    
end

