function F_ViewHeadAngles(mad, varargin)
    % Loading the optional arguments
    AddArgs = ["Colours", "Mode"];
    ArgValues = F_VararginSelection(AddArgs, ...
        {'matrix', 'string'}, ...
        {'', ["Talk", "Default"]}, ...
        {[189, 101, 26; ...
        245, 173, 82; ...
        7, 103, 105]./255, ...
        "Default"}, varargin{:});

    % Adapting the colours given the figure mode
        if ArgValues{"Mode"} == "Talk"
            bkcol = 'k';
            forecol = 'w';
            falpha = 1;
            % Colour modification for constrast
            ArgValues{"Colours"} = ArgValues{"Colours"}.*1.2 + .1;
            ArgValues{"Colours"}(ArgValues{"Colours"} > 1) = 1;
            fw = "bold";
        else
            bkcol = 'w';
            forecol = 'k';
            falpha = .5;
            fw = "normal";
        end



    % Initiating the figure
        figure
        c_ = 1; % Counter
        for angle = ["Yaw", "Pitch", "Roll"]
            subplot(1, 3, c_)
            histogram(mad.Motor.(angle), "FaceColor", ...
                ArgValues{"Colours"}(c_, :), ...
                "EdgeAlpha", 0, "FaceAlpha", falpha);
            title(angle)
            xlabel(angle)
            ylabel("Frames")
            xlim([-180, 180])
            box off

            % Updating the figure given the project figure mode
            f = gca;
            f.Color = bkcol;
            f.XColor = forecol;         f.YColor = forecol;
            f.FontName = mad.RunParams.FigFont; f.FontWeight = fw;

            c_ = c_ + 1; % Counter
        end

        % Changing the figure according to the paramaters
        f = gcf;
        f.Color = bkcol;
        f.Position = [20, 20, 3*420, 420];
        
end

