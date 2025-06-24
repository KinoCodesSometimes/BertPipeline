function F_SensoryMotorPredictionXGB(mad, threshold, Iteration)
%F_SENSORYMOTORPREDICTIONXGB Summary of this function goes here
%   Detailed explanation goes here
% Determining the neurons of interest given the area and curation
good = find(mad.Neurons.ROINeurons + mad.Neurons.GoodUnits_Phy == 2);

% Calculating the distance to the diagonal along with the discrimination
% index
D = abs(mad.XGB.XGB0.Motor.R2 - mad.XGB.XGB0.SSD.R2)./sqrt(2);
DI = (mad.XGB.XGB0.Motor.R2 - mad.XGB.XGB0.SSD.R2) ./ ...
    (mad.XGB.XGB0.Motor.R2 + mad.XGB.XGB0.SSD.R2);

% Establishing the populations
Motor = good(D > threshold & DI > 0);
Sensory = good(D > threshold & DI < 0);

if numel(Sensory) > 1 & numel(Motor) > 1

    %% XGB models
    % Multineuron prediction
    XGBIn.Multi = [];
        XGBIn.Multi.X = cat(2, mad.Neurons.FiringRate{:});
        XGBIn.Multi.Y = XGBIn.Multi.X;
        XGBIn.Multi.X = XGBIn.Multi.X(Motor, :).';
        XGBIn.Multi.Y = XGBIn.Multi.Y(Sensory, :).';      XGBIn.Multi.multi = 1;
        XGBIn.Multi.shuffle = 0;
        XGBIn.Multi.XName = string(Motor);
    
    % Direct neuron-neuron prediction
    XGBIn.Single = [];
        XGBIn.Single.Y = XGBIn.Multi.Y;
        XGBIn.Single.X = XGBIn.Multi.X;
        XGBIn.Single.multi = 1;
        XGBIn.Single.shuffle = 0;
        XGBIn.Single.XName = string(Motor);
    
    % Population-level prediction
    XGBIn.Pop = XGBIn.Multi;
        [~, eigVal, ~, ~, varexp] = pca(XGBIn.Pop.X);
        nComps = F_Scree(varexp, 80);
        XGBIn.Pop.X = eigVal(:, 1:nComps);
        XGBIn.Pop.Y = XGBIn.Multi.Y;
        XGBIn.Pop.multi = 1;
        XGBIn.Pop.shuffle = 0;
        XGBIn.Pop.XName = string(Motor);    
    
    
    %% XGBoosting
    iter_path = mad.RunParams.SaveLoc + "\XGB_" + Iteration;
    mkdir(iter_path)
    models = string(fieldnames(XGBIn));
    
    for model = models.'
        mod_path = iter_path + "\" + model;
        mkdir(mod_path)
        shuffle = XGBIn.(model).shuffle;
        multi = XGBIn.(model).multi;
        XName = XGBIn.(model).XName;
        X = XGBIn.(model).X;    Y = XGBIn.(model).Y;
        save(mod_path + "\" + model, "shuffle", "X", "Y", "multi", "XName")
        mad.XGB.(Iteration).(model).In.XName = XName;
        mad.XGB.(Iteration).(model).In.X = X;
        mad.XGB.(Iteration).(model).In.Y = Y;
    
        % Running XGB
        pyenv(Version = mad.Envs.XGB); 
        F_CallXGBoost(mod_path + "\" + model + ".mat", mod_path)
    
        load(mod_path + "\" + model + ".mat_predicted_final.mat", "Yhat_xgb")
        mad.XGB.(Iteration).(model).R2 = F_R2(Yhat_xgb, Y)
        
        
    end
    
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
    
end
end

