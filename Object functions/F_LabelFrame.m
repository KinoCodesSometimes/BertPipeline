function land_labels = F_LabelFrame(mad, image_path)

% Global function params
end_ = false; % To end the loop
l_ix = 1; % Initial landmark
land_labels = NaN(length(mad.Obj.LandName), 2); % Landmark position output
land_cols = parula(length(mad.Obj.LandName)); % Visualisation consistency
mkdir(mad.Obj.ImagesFolder + "\UserLabels") % Storing the user labels
%% Labelling coordinates
while end_ == false
    % Visualisation
        f = imread(image_path); % ADAPT GIVEN FIG
        imshow(f)
        hold on
        F_PlotPastLands % Ploting already labelled landmarks
        title(mad.Obj.LandName(l_ix)) % UI not
        hold off
    
    % UI
        f = gcf;
        waitforbuttonpress; % UI
        selection = f.CurrentCharacter;

    % User controls
        if strcmp(selection,'a') % Select landmark
            F_LabelFrame % UI
            if l_ix < length(mad.Obj.LandName)
                l_ix = l_ix + 1;
            end
        elseif strcmp(selection, '2') % Go to next landmark
            if l_ix < length(mad.Obj.LandName) % Unless it is the last one
                l_ix = l_ix + 1;
            end
        elseif strcmp(selection, '1') % Go to previous landmark
            if l_ix ~= 1 % Unless we're on the first one
                l_ix = l_ix - 1;
            end
        elseif strcmp(selection, 'd') % Delete landmark
            land_labels(l_ix, :) = [NaN, NaN];
        elseif strcmp(selection, 'c') % Delete all landmarks
            land_labels = zeros(length(mad.Obj.LandName), 2);
            l_ix = 1;
        elseif strcmp(selection, 's') % Save and move on
            end_ = true; % Ending the loop
        elseif strcmp(selection, ' ') % Go to previous
            land_labels = "RETURN";
            end_ = true; % Ending the loop

        end
            


end

%% Supplementing functions
    function F_LabelFrame(~, ~) % UI ginput
        [x, y] = ginput(1);
        land_labels(l_ix, :) = [x, y];
    end

    function F_PlotPastLands(~, ~) % Plots prelabelled lands
        for l = 1:size(land_labels, 1)
            if land_labels(l, :) ~= [NaN, NaN]
                if l == l_ix
                    scatter(land_labels(l, 1), land_labels(l, 2), 400, ...
                        'r', 'filled');
                end 
                scatter(land_labels(l, 1), land_labels(l, 2), 200, ...
                    land_cols(l, :), 'filled');
            end
        end
    end
end

