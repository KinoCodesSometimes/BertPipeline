function F_Scatter(x, y, mode, varargin)
    
    % Optional arguments
    AddArgs = ["XLabel", "YLabel", "Font", "FontSize", "Colour", "Size"];
    ArgValues = F_VararginSelection(AddArgs, ...
        {'string', 'string', 'string', 'double', ...
            ["double", "matrix", "logical"], ...
            ["double", "matrix"]}, ...
        {'', '', '', '', '', ''}, ...
        {"", "", "bahnschrift", 0, false, 100}, varargin{:});

    % Altering the colour scheme for contrast purposes
    if mode == "Talk"
        if islogical(ArgValues{"Colour"})
            ArgValues{"Colour"} = [1, 1, 1];
        else
            ArgValues{"Colour"} = ArgValues{"Colour"}.*1.2 + .12;
            ArgValues{"Colour"}(ArgValues{"Colour"} > 1) = 1;
        end
    end
    
    % Actually plotting
    scatter(x, y, ArgValues{"Size"}, ArgValues{"Colour"}, "filled")
    f = gca;
    f.FontName = ArgValues{"Font"};
    xlabel(ArgValues{"XLabel"})
    ylabel(ArgValues{"YLabel"})

    % Changing the global figure properties given the specified mode
    if mode == "Talk"
        f.Color = 'k';
        f.YColor = 'w';
        f.XColor = 'w';
        f.FontWeight = 'bold';
        f.LineWidth = 1.2;
        if ArgValues{"FontSize"} == 0
            f.FontSize = 15;
        else
            f.FontSize = ArgValues{"FontSize"};
        end
    end
end

