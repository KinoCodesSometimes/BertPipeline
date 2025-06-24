function F_MultiReXGB(mad)
%F_MULTIREXGB Summary of this function goes here
% Re-establishing the environment for the machine
LocalEnvs;
mad.Envs = PCEnvs;

[mad, iter_name] = F_XGBoost(mad, ...
    "Constraint", mad.Neurons.ROINeurons + mad.Neurons.GoodUnits_Phy == 2, ...
    "IterationName", "XGB_ReShuffled");
save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
F_ViewXGB(mad, "Iteration", iter_name)

end

