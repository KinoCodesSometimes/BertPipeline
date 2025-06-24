function [mad] = F_BinUnits(mad)
%F_BINUNITS Summary of this function goes here
%   Detailed explanation goes here

mad.Neurons.FiringRate = cell(1, length(mad.Neurons.Spikes));
for t_ix = 1:mad.Trials
    if length(mad.Timestamps.Events{t_ix})/2 > mad.TrialLen % If too many frames
        warning('on')
        warning("Aberrant number of frames identified. " + ...
            "Was expecting " + mad.TrialLen + " but observed " + ...
            length(mad.Timestamps.Events{t_ix})/2 + ".")
        warning('off')

        % Finding candidate frames
        dff = diff(mad.Timestamps.Events{t_ix}(1:2:end)); % DT
        sds = abs(dff - median(dff))/std(dff); % SDs away from median
        [~, ix] = sort(sds, 1, "descend"); % Sorting 
        outs = ... % Outliers
            ix(1:(length(mad.Timestamps.Events{t_ix})/2 - mad.TrialLen));

        % Visualisation for user validation
        close all
        subplot(1, 3, 1:2)  % Diff and internal time for each up trigger
            yyaxis right
                plot(diff(mad.Timestamps.Events{t_ix}(1:2:end)))
                hold on
            yyaxis right
                scatter(outs, dff(outs), 120, 'r', 'filled', ...
                    'p')
                xlabel("Trigger")
                ylabel("\Delta Time")
                yl = ylim();
            

            yyaxis left
                plot(mad.Timestamps.Events{t_ix}(1:2:end))
                ylabel("Time")
            
            xlim([-1000, mad.TrialLen + 1000])

            box off
            hold off

            ax = gca;
            ax.YColor = 'k';
            ax.FontName = mad.RunParams.FigFont;
   
        subplot(1, 3, 3) % Boxplot of delta t to visualise outlier
        
            boxchart(diff(mad.Timestamps.Events{t_ix}(1:2:end)), ...
                'BoxFaceColor', 'k',  "MarkerColor", 'k', "MarkerSize", .1)
            hold on
            scatter(ones(1, length(outs)), dff(outs), 120, 'r', ...
                'filled', 'p') % Highliting outlier
            box off
            ylim(yl)
            hold off
            axis off

        sgtitle("Outlier triggers in trial " + t_ix, "FontName", ...
            mad.RunParams.FigFont); % Completing figure
        exportgraphics(gcf, mad.RunParams.FigSaveLoc + "\Outliers.pdf", ...
            "Append", true, "ContentType", 'vector') % Saving

        % Excluding outliers from timestamp data
            % Copy of original timestamps
            mad.Timestamps.EventsOG{t_ix} = mad.Timestamps.Events{t_ix};
            mad.Timestamps.StateOG{t_ix} = mad.Timestamps.State{t_ix};

            % Finding all up and down trigger outliers and excluding them
            mad.Timestamps.State{t_ix} = mad.Timestamps.State{t_ix}( ...
                setdiff(1:length(mad.Timestamps.Events{t_ix}), ... % Good frams
                reshape(2*outs - [0; 1], 1, []))); % Both up and down outs

            mad.Timestamps.Events{t_ix} = mad.Timestamps.Events{t_ix}( ...
                setdiff(1:length(mad.Timestamps.Events{t_ix}), ... % Good frams
                reshape(2*outs - [0; 1], 1, []))); % Both up and down outs



    elseif length(mad.Timestamps.Events{t_ix})/2 < mad.TrialLen 
        error("Not enough triggers. " + ...
            "I am affraid that this trial is non-usable. :((")
        % Well, sucks to be you... Double check that your vide has the
        % correct number of frames
        % JRPP - Add option to remove this trial.
    end

    % Binning the neuronal activity
        mad.Neurons.FiringRate{t_ix} = ... % Storage
            zeros(length(mad.Neurons.Depths), mad.TrialLen-1);
        
        for n_ix = 1:length(mad.Neurons.Depths) % Iterating per unit
            mad.Neurons.FiringRate{t_ix}(n_ix, :) = histcounts( ...
                mad.Neurons.Spikes{t_ix}{n_ix}, ... % Neuron spikes
                mad.Timestamps.Events{t_ix}( ... % Triggers
                    mad.Timestamps.State{t_ix} ~= 0)); % Up constraint
        end

        % Determining stim from the NiDaq (if exists)
        if ~isempty(mad.Timestamps.NiDaq)
            mad.Timestamps.NiDaqSynch{t_ix} = zeros(8, mad.TrialLen-1);
            for ch_ix = 1:8
                mad.Timestamps.NiDaqSynch{t_ix}(ch_ix, :) = ...
                    histcounts(mad.Timestamps.NiDaq{t_ix}.Timestamp{ch_ix}(... % NiDaq Triggers
                        mad.Timestamps.NiDaq{t_ix}.State{ch_ix} == 1, :), ... % Up constraint
                    mad.Timestamps.Events{t_ix}( ... % Triggers
                        mad.Timestamps.State{t_ix} ~= 0)); % Up constraint
            end
        end
        
        % Expressing it as Hz
        mad.Neurons.FiringRate{t_ix} = ...
            mad.Neurons.FiringRate{t_ix} ./ mad.FPS;

end
end

