function mad = F_UILabelObj(mad)

    F_Description % UI explanation window

    mad.Obj.Labels = cell(1, length(mad.Obj.ObjTrials));

    % Creating index of trials and cameras per frame
    fr_ix = repelem(mad.Obj.ObjTrials, mad.NCams);
    fr_ix(2, :) = repmat(1:mad.NCams, 1, length(mad.Obj.ObjTrials));
    end_ = false;
    c_ = 1; % Counter

    % Saving the figures
    mad.Obj.LabelFigs = cell(1, length(mad.Obj.ObjTrials));

    while end_  == false
        user_labels = F_LabelFrame(mad, mad.Obj.ImagesFolder + ...
                "\ObjectFrame_Trial_" + fr_ix(1, c_) + ...
                "_Camera_" + fr_ix(2, c_) + ".png");
        if class(user_labels) == 'string' %#ok<BDSCA>
            if c_ ~= 1
                c_ = c_ - 2;
            end
        else
            mad.Obj.Labels{fr_ix(1, c_)}{fr_ix(2, c_)} = user_labels;
            mad.Obj.LabelFigs{c_} = gcf;
        end

        % Breakin the chain
        if c_ == length(fr_ix)
            end_ = true;
            mad.Prog.ObjLabel = true;
        end

        c_ = c_ + 1; % Updating the counter
    end

    function F_Description(~, ~)
        instr = ["1 and 2 to move between landmarks.", ...
                "a to place a landmark.", ...
                "d to delete the current landmark.", ...
                "c to clear all the landmarks.", ...
                "s once you're done labelling the object.", ...
                "SPACE to go to the previous image."];

        mw = uifigure("Position", [100, 100, 300, 300]);
        uicontrol("Parent", mw, "Style", "text", "String", instr, ...
            "Position", [20, 20, 260, 260])
    end

    mad.Prog.ObjLabel = datetime("now");

end

