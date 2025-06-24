function [mad, iter_name] = F_XGBoost(mad, varargin)
%F_XGBOOST Summary of this function goes here
%   Detailed explanation goes here
% Loading the optional arguments

    AddArgs = ["Constraint", "IterationName"];
    ArgValues = F_VararginSelection(AddArgs, ...
        {'logical', ["string", "double"]}, ...
        {'', ''}, ...
        {ones(size(mad.Neurons.GoodUnits)), "XGB0"}, varargin{:}); % By default run all neurons

%% Defining the models
    models = string(fieldnames(mad.Models)).';
    xdata = [];
    for f = string(fieldnames(mad.Motor)).'
        xdata.(f) = mad.Motor.(f)(mad.Obj.ObjTrials);
    end

%% Finding previous iterations to avoide overwriting past data
% Defining the iteration name
iter_name = ArgValues{"IterationName"};

% If already existing, add name tag
if sum(string({dir(mad.RunParams.SaveLoc).name}) == iter_name) > 0
    iter_name = iter_name + "_" + string(datetime);
end

%% Standard run of models
for model = models

    % Storage
    mkdir(mad.RunParams.SaveLoc + "\" + iter_name + "\" + model)

    % Binning
    fBin = @(x) F_BinShift(x, mad.BinWidth);
    vars = F_ApplyToStruct(fBin, xdata, mad.Models.(model), ...
        "Annex", false); % Motor vars
    neurons = F_BinShift(mad.Neurons.FiringRate(mad.Obj.ObjTrials), ...
        mad.BinWidth); % Neurons
    clear fBin

    % Merging trials
    fMerge = @(x) cat(2, x{:});
    vars = F_ApplyToStruct(fMerge, vars, [], ...
        "Annex", false);
    neurons = fMerge(neurons);
    clear fMerge

    % Merging struct vars
    X = zeros(size(neurons, 2), length(mad.Models.(model)));
    for var_ix = 1:length(mad.Models.(model))
        X(:, var_ix) = vars.(mad.Models.(model)(var_ix));
    end


    % Generating XGBoost data
    Y = neurons(ArgValues{"Constraint"}, :).';      multi = 1;
    shuffle = 0;    XName = mad.Models.(model);

    % Saving
    save(mad.RunParams.SaveLoc + "\" + iter_name + "\" + model + "\" + ...
        model, "shuffle", "X", "Y", "multi", "XName")
    mad.XGB.(ArgValues{"IterationName"}).(model).In.XName = XName;
    mad.XGB.(ArgValues{"IterationName"}).(model).In.X = X;
    mad.XGB.(ArgValues{"IterationName"}).(model).In.Y = Y;

    % Running XGBOOST
    pyenv(Version = mad.Envs.XGB);
    F_CallXGBoost(mad.RunParams.SaveLoc + "\" + iter_name + "\" + ...
        model + "\" + model + ".mat", ...
        mad.RunParams.SaveLoc + "\" + iter_name + "\" + model)

    load(mad.RunParams.SaveLoc + "\" + iter_name + "\" + ...
        model + "\" + model + ".mat_predicted_final.mat", "Yhat_xgb")
    mad.XGB.(ArgValues{"IterationName"}).(model).R2 = F_R2(Yhat_xgb, Y);


    % Shuffling
    shuffledR2 = zeros(20, size(Yhat_xgb, 2));
    good_Y = Y;
    for shuff_ix = 1:20
        Y = Y([100:size(Y, 1), 1:99], :); % Temporal delayed shuffle
        % Y = good_Y(randperm(size(Y, 1)), :); % Complete shuffling
        save(mad.RunParams.SaveLoc + "\" + iter_name + "\" + ...
            model + "\" + model + "_Shuffle_" + shuff_ix, ...
            "shuffle", "X", "Y", "multi", "XName")

        F_CallXGBoost(mad.RunParams.SaveLoc + "\" + iter_name + "\" + ...
            model + "\" + model + "_Shuffle_" + shuff_ix + ".mat", ...
            mad.RunParams.SaveLoc + "\" + iter_name + "\" + model)
        load(mad.RunParams.SaveLoc + "\" + iter_name + "\" + ...
            model + "\" + model + "_Shuffle_" + shuff_ix + ...
            ".mat_predicted_final.mat", "Yhat_xgb")
        shuffledR2(shuff_ix, :) = F_R2(Yhat_xgb, Y);
    end
    mad.XGB.(ArgValues{"IterationName"}).(model).Shuffles = shuffledR2;
end

end

