function F_AssessObjects(mad)

    %% PLOT ALL OBJECT TRIALS

    if mad.RunParams.FigMode == "Talk"
            bkcol = 'k';
            forecol = 'w';
            fw = "bold";
        else
            bkcol = 'w';
            forecol = 'k';
            fw = "normal";
    end

    cols = mad.RunParams.Palette(floor(linspace(1, ...
        length(mad.RunParams.Palette), ...
        length(mad.Obj.Triangulated) + 2)), :);
    for t_ix = 1:length(mad.Obj.Triangulated)
        scatter3(mad.Obj.Triangulated{t_ix}(:, 1), ...
            mad.Obj.Triangulated{t_ix}(:, 2), ...
            mad.Obj.Triangulated{t_ix}(:, 3), 100, cols(t_ix + 1, :), ...
            "filled", "MarkerFaceAlpha", .9)
        hold on
    end
    axis equal
    hold off

    f = gca;
    f.Color = bkcol;
    f.XColor = forecol;         f.YColor = forecol;
    f.ZColor = forecol;
    f.FontName = "bahnschrift"; f.FontWeight = fw;

    f = gcf;
    f.Color = bkcol;

    leg = legend("Trial " + mad.Obj.ObjTrials);
    leg.TextColor = forecol;
    exportgraphics(gcf, ...
        mad.RunParams.FigSaveLoc + "\ObjectProcessing.pdf", ...
        "Append", false, "ContentType", "vector")
    saveas(gcf, mad.RunParams.FigSaveLoc + "\ObjectTriangulation_Landmarks")


    %% PLOTTING OBJECT SURFACE (location validation)
    hold off
    for t_ix = 1:length(mad.Obj.Mesh)
        trisurf(boundary(mad.Obj.Mesh{t_ix}(:, 1), ...
            mad.Obj.Mesh{t_ix}(:, 2), mad.Obj.Mesh{t_ix}(:, 3)), ...
            mad.Obj.Mesh{t_ix}(:, 1), ...
            mad.Obj.Mesh{t_ix}(:, 2), mad.Obj.Mesh{t_ix}(:, 3), ...
            "FaceAlpha", 0.2, "FaceColor", cols(t_ix + 1, :), ...
            "LineStyle", "none")
        hold on
        if ~isempty(mad.Obj.Additional)
            for i = 1:length(mad.Obj.Additional{t_ix})
                plot3(mad.Obj.Additional{t_ix}{i}(:, 1), ...
                    mad.Obj.Additional{t_ix}{i}(:, 2), ...
                    mad.Obj.Additional{t_ix}{i}(:, 3), ...
                    "Color", cols(t_ix + 1, :), "LineWidth", 2)
            end
        end 
    end
    xlabel("X");    ylabel("Y");    zlabel("Z")
    title("Object meshes", 'Color', forecol)
    hold off
    axis equal
    

    f = gca;
    f.Color = bkcol;
    f.XColor = forecol;         f.YColor = forecol;
    f.ZColor = forecol;
    f.FontName = "bahnschrift"; f.FontWeight = fw;

    exportgraphics(gcf, ...
        mad.RunParams.FigSaveLoc + "\ObjectProcessing.pdf", ...
        "Append", true, "ContentType", "image")
    saveas(gcf, mad.RunParams.FigSaveLoc + "\ObjectTriangulation_AllMeshes")

    hold off


    %% PLOTTING SURFACE PLUS FIT
    for t_ix = 1:length(mad.Obj.Mesh)
        try
            ax1 = subplot(1, 2, 1);     ax2 = subplot(1, 2, 2);
    
            % Ax1
            for i = 1:length(mad.Obj.Additional{t_ix})
                plot(ax1, mad.Obj.Additional{t_ix}{i}(:, 1), ...
                    mad.Obj.Additional{t_ix}{i}(:, 2), ...
                    "Color", forecol, "LineWidth", 2)
                hold(ax1, 'on')
            end
            xlabel(ax1, "X");   ylabel(ax1, "Y");
            
            hold(ax1, "off")
            axis(ax1, "Equal")
            box(ax1, "off")
            title(ax1, "Object fit", 'Color', forecol)
    
            % Ax2
            % 3d plot
            trisurf(boundary(mad.Obj.Mesh{t_ix}(:, 1), ...
                mad.Obj.Mesh{t_ix}(:, 2), mad.Obj.Mesh{t_ix}(:, 3)), ...
                mad.Obj.Mesh{t_ix}(:, 1), ...
                mad.Obj.Mesh{t_ix}(:, 2), mad.Obj.Mesh{t_ix}(:, 3), ...
                "FaceAlpha", 0.2, "FaceColor", forecol, ...
                "LineStyle", "none", "Parent", ax2)
            hold(ax2, "on")
            
    
            % Fit
            for i = 1:length(mad.Obj.Additional{t_ix})
                plot3(ax2, mad.Obj.Additional{t_ix}{i}(:, 1), ...
                    mad.Obj.Additional{t_ix}{i}(:, 2), ...
                    mad.Obj.Additional{t_ix}{i}(:, 3), ...
                    "Color", forecol, "LineWidth", 2)
            end
    
            % Points
            scatter3(ax2, mad.Obj.Triangulated{t_ix}(:, 1), ...
                mad.Obj.Triangulated{t_ix}(:, 2), ...
                mad.Obj.Triangulated{t_ix}(:, 3), 50, forecol, "Filled")
            xlabel(ax2, "X");   ylabel(ax2, "Y");   zlabel(ax2, "Z");
            
            hold(ax2, "off")
            axis(ax2, "Equal")
            title(ax2, "Object surface", 'Color', forecol)
            
    
            % Setting the axes colours
                ax1.Color = bkcol;
                ax1.XColor = forecol;         ax1.YColor = forecol;
                ax1.ZColor = forecol;
                ax1.FontName = "bahnschrift"; ax1.FontWeight = fw;
                ax2.Color = bkcol;
                ax2.XColor = forecol;         ax2.YColor = forecol;
                ax2.ZColor = forecol;
                ax2.FontName = "bahnschrift"; ax2.FontWeight = fw;
            f = gcf;
            sgtitle(f, "Trial " + mad.ObjectTrials(t_ix) + " object fit", ...
                'Color', forecol, "FontName", "bahnschrift")
            f.Color = bkcol;
            
            exportgraphics(f, ...
                mad.RunParams.FigSaveLoc + "\ObjectProcessing.pdf", ...
                "Append", true, "ContentType", "vector")
        catch
        
    end


end

