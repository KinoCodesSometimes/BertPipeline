%% Identifying all burst events
function [mad] = F_GenerateBTAs(mad, varargin)
%% Optional vars
    % Loading the optional arguments
    AddArgs = ["MotorVar", "Pre", "Post", "ITI", "ViewBursts"];
    ArgValues = F_VararginSelection(AddArgs, ...
        {['string', 'list'], 'double', 'double', 'double', 'logical'}, ...
        {'', '', '', '', ''}, ...
        {setdiff(string(fieldnames(mad.Motor)).', ["Loco", "dLoco"]), ...
            10, 20, 1/150, true}, varargin{:});

%% Global vars
    mvars = ArgValues{"MotorVar"};
    x = (-ArgValues{"Pre"}):ArgValues{"Post"};

    % Organising outputs
    mkdir(mad.RunParams.FigSaveLoc + "/BTAs") % Output folder
    BTs = zeros(length(mad.Neurons.Depths), length(mvars)); % BTA score
    BTAs = cell(1, length(mad.Neurons.Depths)); % Burst-triggered averages.
    BTAs_sd = cell(1, length(mad.Neurons.Depths)); % Burst-triggered sds.
    Bursts = cell(1, mad.Trials); % Burst locations
    burst_bin = cell(1, mad.Trials); % Binned bursts

%% Identifying bursts
    for t_ix = 1:mad.Trials
        for n_ix = 1:length(mad.Neurons.Spikes{t_ix})

            % Identifying spikes with ITI < 7 ms 
            % https://journals.physiology.org/doi/full/10.1152/jn.1999.82.2.754
            Bursts{t_ix}{n_ix} = mad.Neurons.Spikes{t_ix}{n_ix}(...
                strfind(strjoin(string(double(diff( ...
                mad.Neurons.Spikes{t_ix}{n_ix}) < ...
                ArgValues{"ITI"})).', ""), "0111")+1);             
        end
    end

%% Visualising bursts
    if ArgValues{"ViewBursts"} == true
        close all
        for n_ix = 1:length(mad.Neurons.Spikes{1})
            if isempty(mad.Neurons.Spikes{1}{n_ix}) == 0
                scatter(mad.Neurons.Spikes{1}{n_ix}, ...
                    n_ix.*ones(size(mad.Neurons.Spikes{1}{n_ix})), 10, ...
                    'k', 'filled')
        
                hold on
        
                if isempty(Bursts{1}{n_ix}) == 0
                    scatter(Bursts{1}{n_ix}, ...
                        n_ix.*ones(size(Bursts{1}{n_ix})), ...
                        30, 'r', 'filled')
                end
            end
        end
        hold off
        xlabel("Time (s)")
        ylabel("Neurons")
        fontname(mad.RunParams.FigFont)
        saveas(gcf, mad.RunParams.FigSaveLoc + "/Bursts", 'fig')
    end

%% Associating BCam bins to burst events
    
    for t_ix = 1:mad.Trials
        burst_bin{t_ix} = zeros(length(mad.Neurons.Depths), ...
            mad.TrialLen-1);
        for n_ix = 1:numel(mad.Neurons.Depths)
            burst_bin{t_ix}(n_ix, :) = histcounts(Bursts{t_ix}{n_ix}, ...
                mad.Timestamps.Events{t_ix}(...
                    mad.Timestamps.State{t_ix} ~= 0));
        end
    end

%% Computing the burst-triggered average per neuron

% Iterating per neurons
for n_ix = 1:length(mad.Neurons.Depths)


    % If figures have been previously generated, erase them
    if isfile(mad.RunParams.FigSaveLoc + "/BTAs/" + n_ix + ".pdf")
        delete(mad.RunParams.FigSaveLoc + "/BTAs/" + n_ix + ".pdf")
    end

    % Creating empty storage array for each neuron
    BTAs{n_ix} = zeros(length(mvars), length(x));
    BTAs_sd{n_ix} = BTAs{n_ix};

    v_c = 1; % Motor variable counter

    for v_ix = mvars
        bta = []; % Storage
        

        for t_ix = mad.Obj.ObjTrials
            bursts = find(burst_bin{t_ix}(n_ix, :) == 1); % Finding bursts
            z_ = zscore(mad.Motor.(v_ix){t_ix});
            if isempty(bursts) == 0 % Storing associated motor variables
                bursts(bursts<(ArgValues{"Pre"}+1) | ...
                    bursts>(mad.TrialLen - 1 - ArgValues{"Post"})) = [];
                bta = [bta; z_(bursts.'+x)];
            end

        end

        if ~isempty(bta) && size(bta, 1) > 30
            % Determining significance
            BTs(n_ix, v_c) = ...
                (mean(mean(bta(:, ArgValues{"Pre"} + (1:6)))) - ...
                mean(mean(bta(:, 1:ArgValues{"Pre"})))) ./ ...
                std(mean(bta(:, 1:ArgValues{"Pre"})));
            
            % Writing Storage
            BTAs{n_ix}(v_c, :) = mean(bta);
            BTAs_sd{n_ix}(v_c, :) = std(bta);

            % Visualising the units if significant
            if abs(BTs(n_ix, v_c)) > norminv(.99)

                % Error bar
                F_FillArea(mean(bta), std(bta)./sqrt(size(bta, 1)), ...
                    mad.RunParams.Palette(250, :), x./mad.FPS)
                hold on

                % Mean
                plot(x./mad.FPS, mean(bta), "Color", ...
                    mad.RunParams.Palette(90, :), "LineWidth", 2)

                % Completing visualisation
                hold off
                ylabel(v_ix + "(Z)")
                xlabel("Time (s)")
                box off
                title("\DeltaX \cdot \sigma^{-1}_{pre} = " + BTs(n_ix, v_c))
                xline(0, "LineWidth", 1.5, "LineStyle", "-")
                fontname(mad.RunParams.FigFont)

                % Storage
                exportgraphics(gcf, ...
                    mad.RunParams.FigSaveLoc + "/BTAs/" + n_ix + ".pdf", ...
                    "Append", true, "ContentType", "vector")
            end
        end
        v_c = v_c + 1;
    end

end

%% Viewing overall BTA responses

imagesc(BTs)
    xticks(1:length(mvars))
    xticklabels(mvars)
    box off
    ylabel("Neuron")
    colormap(mad.RunParams.Palette)
    cbr = colorbar;
    cbr.Label.String = "\DeltaX\cdot\sigma^{-1}_{Xpre}";
    fontname(mad.RunParams.FigFont)


mad.SupMotor.BTA.Scores = BTs;
mad.SupMotor.BTA.Bursts = Bursts;
mad.SupMotor.BTA.BinnedBursts = burst_bin;
mad.SupMotor.BTA.MotorVar = mvars;
mad.SupMotor.BTA.BTAs = BTAs;
mad.SupMotor.BTA.BTA_sd = BTAs_sd;
mad.SupMotor.BTA.ITI = ArgValues{"ITI"};

end