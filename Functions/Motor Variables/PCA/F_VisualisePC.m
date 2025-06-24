function F_VisualisePC(mad, Components)

for c = Components
    v = VideoWriter(mad.RunParams.FigSaveLoc + "\PC" + c + " Sample.avi");
    open(v)
    
    
    % Final vis prep
        subplot(4, 3, 10:12)
        h = histogram(mad.SupMotor.PCA(:, c), "Normalization", "probability");
        box off
        ylabel("P(PC" + c + ")")
        xlabel("PC" + c)
        if mad.RunParams.FigMode == "Talk"
            bkcol = 'k';
            forcol = 'w';
        end
    
    % Establishing the visualisation interval
        msearch = find(cumsum(h.Values)>.005, 1)+1;
        mxsearch = find(cumsum(h.Values)>.995, 1);
    
        % And the steps
        int = h.BinEdges([msearch, mxsearch]) + h.BinWidth*.5;
        int = int(1):(sum(abs(int))/100):int(2);
        int = [int, flip(int(2:end-1))];
    
        % Generating the synthetic eigenvalues
        SynthEigVal = zeros([length(int), ...
            size(mad.SupMotor.EigenVects, 1)]);
        SynthEigVal(:, c) = int.';
    
    % Generating the poses
        Reconstruction = ...
            zeros([length(mad.SupMotor.MeanPose)/3, 3, length(int)]);
        for f_ix = 1:size(SynthEigVal, 1)
            Reconstruction(:, :, f_ix) = ...
                reshape(SynthEigVal(f_ix, :)*(mad.SupMotor.EigenVects.') + ...
                mad.SupMotor.MeanPose, 3, []).';
        end
    
        % Estimating the lims for the visualisations
        lims = [min(Reconstruction, [], [1, 3]).', ...
            max(Reconstruction, [], [1, 3]).'];
    
    % Plotting the pose
        for f_ix = 1:size(SynthEigVal, 1)

            % Somewhat redundant for the next 30 lines...
            % Right pannel
            subplot(4, 3, 1:3:7)
            cla
            F_PlotPose(mad.RunParams.MouseVis, ...
                Reconstruction(:, :, f_ix), ...
                "xLim", lims(1, :), "yLim", lims(2, :), ...
                "zLim", lims(3, :), "Mode", mad.RunParams.FigMode);
            view(-30, 90)
        
            % Middle pannel
            subplot(4, 3, 2:3:8)
            cla
            F_PlotPose(mad.RunParams.MouseVis, ...
                Reconstruction(:, :, f_ix), ...
                "xLim", lims(1, :), "yLim", lims(2, :), ...
                "zLim", lims(3, :), "Mode", mad.RunParams.FigMode);
            view(-30, 20)
        
            % Left pannel
            subplot(4, 3, 3:3:9)
            cla
            F_PlotPose(mad.RunParams.MouseVis, ...
                Reconstruction(:, :, f_ix), ...
                "xLim", lims(1, :), "yLim", lims(2, :), ...
                "zLim", lims(3, :), "Mode", mad.RunParams.FigMode);
            view(-30, 0)
            
            % Visualising PC histogram
            subplot(4, 3, 10:12)
            h = histogram(mad.SupMotor.PCA(:, c), "Normalization", ...
                "probability", "FaceColor", forcol);

            % Finishing the figure
            f = gca;
            f.Color = bkcol;
            f.FontName = "bahnschrift";
            f.Color = bkcol;          
            f.XColor = forcol;         f.YColor = forcol;
            box off
            ylabel("P(PC" + c + ")")
            xlabel("PC" + c)
            hold on
            xline(int(f_ix), "LineWidth", 2, "Color", forcol, "Alpha", 1)
            hold off
            set(gca,'fontsize',14)
            f = gcf;
            f.Position = [280, 74, 1409, 850];
            writeVideo(v, getframe(gcf))
        end
    
    close(v)
end
end