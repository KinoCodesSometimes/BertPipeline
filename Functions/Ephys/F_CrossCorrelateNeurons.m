function F_CrossCorrelateNeurons(mad, N1, N2, varargin)
% N1 and N2 are the indecies of the neruons that want to be cross
% correlated. Output will be the croscorrelation between every member of N1
% and N2.
% Inputs:
    % mad - MAD pipeline storage struct
    % N1, N2 - Neuron indecies to correlate.
    % OPTIONAL
        % BinEdges - Edges of the bins for the cross-correlation
        % Shuffles - Number of jitter shuffles to perform.
        % MaxJitter - Maxiumum jitter for shuffles (in ms)
        % SignificanceThreshold - p for significance
        % Colour - RGB for the visualisation

    %% Setting the parameters
    % Loading the optional arguments
    load("Rusco.mat", "Rusco")
    AddArgs = ["BinEdges", "Shuffles", "MaxJitter", ...
        "SignificanceThreshold", "Colour", "SaveName"];
    ArgValues = F_VararginSelection(AddArgs, ...
        {'matrix', 'double', 'double', 'double', 'matrix', 'string'}, ...
        {'', '', '', '', '', ''}, ...
        {-50.5:50.5, 100, 20, .005, Rusco(250, :), "CrossCorr.pdf"}, ...
        varargin{:});

    % Defining the bin centres for the visualisation
    x = ArgValues{"BinEdges"}(2:end)-mean(diff(ArgValues{"BinEdges"}))./2;

    %% Cross-correlation
    for n_i = N1
        for n_j = N2

            % Storage
            isd = zeros(size(ArgValues{"BinEdges"}) - [0, 1]);
            isd_jitter = zeros(ArgValues{"Shuffles"}, ...
                size(ArgValues{"BinEdges"}, 2)-1);

            % Iterating per trial
            for t_ix = 1:mad.Trials
    
                % Computing the interspike distance
                isd = isd + histcounts((mad.Neurons.Spikes{t_ix}{n_i} - ...
                    mad.Neurons.Spikes{t_ix}{n_j}.').*1000, ...
                    ArgValues{"BinEdges"});
    
                %% Shuffling
                for sh_ix = 1:ArgValues{"Shuffles"}
                    isd_jitter(sh_ix, :) = isd_jitter(sh_ix, :) + ....
                        histcounts(...
                        (mad.Neurons.Spikes{t_ix}{n_i} - ...
                        (mad.Neurons.Spikes{t_ix}{n_j} + ...
                            rand(size(mad.Neurons.Spikes{t_ix}{n_j})) .* ... % Jittering
                            ((ArgValues{"MaxJitter"}.*2)./1000) - ...
                            ArgValues{"MaxJitter"}./1000).') .* ...
                            1000, ArgValues{"BinEdges"});
                end
            end
            % Estimating the significance
            sig = (sum(isd_jitter > isd)+1)./(isd + 1) < ...
                ArgValues{"SignificanceThreshold"};

            %% Visualising
            plot(x, isd, "LineWidth", 1.5, "Color", ArgValues{"Colour"})
            hold on
            F_FillArea(mean(isd_jitter, 1), ...
                norminv(.99).*std(isd_jitter, [], 1), ...
                ArgValues{"Colour"}, x)
            scatter(x(sig), isd(sig), 50, ArgValues{"Colour"}, "filled")
    
            % Completing the visual
            hold off
            box off
            title([n_i, n_j])
            xlabel("T (ms)")
            ylabel("Spike count")
            fontname(mad.RunParams.FigFont)

            % Saving figures
            exportgraphics(gcf, mad.RunParams.FigSaveLoc + "\" + ...
                ArgValues{"SaveName"}, "Append", true, ...
                "ContentType", "vector")
    
        end
    end
end

