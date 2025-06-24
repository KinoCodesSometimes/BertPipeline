function F_SensoryMotorCrossCorr(mad, threshold)
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
    F_CrossCorrelateNeurons(mad, Sensory.', Motor.', ...
        "SignificanceThreshold", 0.001)   
end
end

