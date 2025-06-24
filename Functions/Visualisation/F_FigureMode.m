function [f] = F_FigureMode(f, mad, varargin)
    if mad.RunParams.FigMode == "Talk"
        bkcol = 'k';
        forecol = 'w';

    else
        bkcol = 'w';
        forecol = 'k';

    end

    % Changing the background
    f.Color = bkcol;

    % Finding axes
    axs = findall(f,'type','axes');

    
    for ax_ix = 1:length(axs)
        % Changing the title
        F_CorrTitle(axs(ax_ix))

        % Changing the colours
        axs(ax_ix).Color = bkcol;
        axs(ax_ix).XColor = forecol;         axs(ax_ix).YColor = forecol;
        axs(ax_ix).FontName = mad.RunParams.FigFont; 
        try %#ok<TRYNC>
            axs(ax_ix).ZColor = forecol; 
        end


        
    end

    if nargin > 2
        for v_ix = 3:nargin
            varargin{v_ix-2}.Box = 'off';
            varargin{v_ix-2}.FontName = mad.RunParams.FigFont;
            varargin{v_ix-2}.Color = forecol;
        end
    end
    

    
    function F_CorrTitle(ax)
        if ~isempty(ax.Title.String)
            ax.Title.FontName = mad.RunParams.FigFont;
            ax.Title.Color = forecol;
        end
    end


end

