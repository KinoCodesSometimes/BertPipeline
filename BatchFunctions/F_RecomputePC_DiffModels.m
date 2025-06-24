function [PCs] = F_RecomputePC_DiffModels(mad)
    %F_RECOMPUTEPC_DIFFMODELS Summary of this function goes here
    %   Detailed explanation goes here
    % Clearing current PCA data
    mad.RunParams.PCA_PoseBank = "PC_PoseBank";
    mad.Motor = [];
    mad = F_PCMotorVariable(mad);
    pc_v1 = [mad.Motor.PC1; mad.Motor.PC2; mad.Motor.PC3];
    
    mad.RunParams.PCA_PoseBank = "SC_PoseBank";
    mad.Motor = [];
    mad = F_PCMotorVariable(mad);
    pc_v2 = [mad.Motor.PC1; mad.Motor.PC2; mad.Motor.PC3];
    
    PCs = [pc_v1.', pc_v2.'];
end

