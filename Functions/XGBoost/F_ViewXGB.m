function F_ViewXGB(mad, varargin)

    % Loading the optional arguments
    ArgValues = F_VararginSelection(["Mode", "Iteration"], ...
        {'string', 'string'}, ...
        {["Talk", "Default"], ''}, ...
        {"Default", "XGB0"}, varargin{:});
    
        % Adapting the colours given the figure mode
            if ArgValues{"Mode"} == "Talk"
                bkcol = 'k';
                forecol = 'w';
                falpha = 1;
                fw = "bold";
            else
                bkcol = 'w';
                forecol = 'k';
                falpha = .5;
                fw = "normal";
            end
    
    
    models = ...
        setdiff(string(fieldnames(mad.XGB.(ArgValues{"Iteration"}))), ...
        "Tuning").';
    Ref = "Full";
    
    [~, ix] = sort(mad.XGB.(ArgValues{"Iteration"}).(Ref).R2, 2, "descend"); % Determining sort index
    cols = [50, 100, 200];
    
    for m_ix = 1:length(models)
        models(m_ix)
        plot(mad.XGB.(ArgValues{"Iteration"}).(models(m_ix)).R2(ix), ...
            "Color",  mad.RunParams.Palette(cols(m_ix), :), ...
            "LineWidth", 2)
        hold on
        mu = mean(mad.XGB.(ArgValues{"Iteration"}).(models(m_ix)).Shuffles(:, ix), 1);
        ci = nanstd(mad.XGB.(ArgValues{"Iteration"}).(models(m_ix)).Shuffles(:, ix), [], 1).*...
            norminv(.99);
        F_FillArea(mu, ci, mad.RunParams.Palette(cols(m_ix), :), 1:length(ix))
    
    end
    hold off
    
    l = repelem(models, 2);
    l(2:2:end) = "";
    l = legend(l);
    
    xlabel("Neuron")
    ylabel("R^2")
    box off
    
    % Updating the figure given the project figure mode
    f = gca;
    f.Color = bkcol;
    f.XColor = forecol;         f.YColor = forecol;
    f.FontName = mad.RunParams.FigFont;     f.FontWeight = fw;
    l.FontName = mad.RunParams.FigFont;     l.FontWeight = fw;
    l.TextColor = forecol;     l.Box = 'off';
    
    f = gcf;
    f.Position = [900, 440, 800, 500];
    f.Color = bkcol;
    exportgraphics(f, mad.RunParams.FigSaveLoc + "\XGBout" + ....
        ArgValues{"Iteration"} + ".pdf", ...
        "ContentType", "vector")
end
