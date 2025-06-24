function [mad] = F_BombcellCurate(mad)


%% Checking consistency between oebin files
    bin_fls = cell(1, length(mad.Ephys.CatFolders));
    for fl_ix = 1:length(mad.Ephys.CatFolders)
        fl = fopen(mad.Ephys.CatFolders(fl_ix) + ... % JRPP - Correct for assumption of NPX2.0
            "\Record Node 101\experiment1\recording1\structure.oebin");
        bin_fls{fl_ix} = fread(fl);
    end

    if length(unique(cellfun(@length, bin_fls))) == 1 % Checking for same size
        bin_vers = size(unique(cat(2, bin_fls{:}).', 'rows').', 2); % Searching repeated columns
        if bin_vers > 1
            warning('on')
            warning("Multiple versions of the oebin " + ...
                "structure file have been identified." + ...
                " Calling Phy for cluster validation")
            warning('off')
            % JRPP - Follow up on this warning.
        else
            bin_file = mad.Ephys.CatFolders(1) + ...
                "\Record Node 101\experiment1\recording1\structure.oebin";
        end
    end

%% Determining parameters
    % Number of recorded channels
    load(mad.Ephys.ChanMap, "xcoords")
    nChans = length(xcoords); % Expecting 384 for NPX2.0 but checking jic
    clear xcoords

    % Creating savepath
    savepath = mad.RunParams.SaveLoc + "\BombCell curation";
    mkdir(savepath)


%% BOMBCELL
% Loading the data
[spikeTimes_samples, spikeTemplates, templateWaveforms, ...
    templateAmplitudes, pcFeatures, pcFeatureIdx, channelPositions] = ...
    bc.load.loadEphysData(char(mad.Ephys.KiloPath + "\"));

% Quality metrics
param = bc.qm.qualityParamValues(dir(bin_file), ...
    char(mad.Ephys.Concatenated), char(mad.Ephys.KiloPath  + "\"), ...
    NaN, 4);

param.nChannels = nChans;
param.nSyncChannels = 0; % Assuming 0, different for Riccardos' setup jic

% Running bombcell
close all
[qMetric, unitType] = bc.qm.runAllQualityMetrics(param, ...
    spikeTimes_samples, spikeTemplates,  templateWaveforms, ...
    templateAmplitudes, pcFeatures, pcFeatureIdx, channelPositions, ...
    char(savepath + "\"));

% Counting good units
    good_units = (unitType == 1 | unitType == 3);
    nGood = sum(logical(good_units));

% Visualisation
fig_freq = figure; % To prevent overlap with BombCell figs

    % Extracting rel frequencies
    t = tabulate(unitType);
    t = t([2, 4, 1, 3], 3);    
    labels = ["Good somatic", "Good non-somatic", "Noise", "MUA"];

    % Generating visual
    piechart(fig_freq, t, labels)
    cols = mad.RunParams.Palette(round(linspace(... % Colouring
        1, length(mad.RunParams.Palette), length(labels) + 2)), :);
    colororder(cols(2:end-1, :))

    ax = gca; % Completing in accordance to project parameters
    ax.FontName = mad.RunParams.FigFont;

    % Generating a title
    sgtitle(nGood + " good neurons out of " + ...
        length(unitType) + " units.", ...
        "FontName", mad.RunParams.FigFont)


fgs = findall(groot,'Type','figure'); % Gathering all figures
for fg_ix = 1:length(fgs)
   exportgraphics(fgs(fg_ix), ... % Exporting
       mad.RunParams.FigSaveLoc + "\Bombcell.pdf", "Append", true, ...
       "ContentType", "vector")
end


save(savepath + "\BombcellParams", "param", "spikeTimes_samples", ...
    "spikeTemplates",  "templateWaveforms", "templateAmplitudes", ...
    "pcFeatures", "pcFeatureIdx", "channelPositions", "qMetric", ...
    "unitType")

mad.Neurons.GoodUnits = good_units;
mad.Neurons.Quality = qMetric;
close all
end

