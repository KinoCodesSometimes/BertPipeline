function mad = F_GetSOD(mad)
close all

% Defining the non-linear sigmoid function
beta = 2;
f = @(x) 2./(1+exp(-beta*x))-.5; 

% Storage
mad.Motor.SOD = nan(1, size(mad.Mouse.Refined, 3));

c_ = 1;
% Iterating through object-bearing trials
for t_ix = mad.Obj.ObjTrials
    
    % Snout coords
    snt = mad.Mouse.Refined(mad.Mouse.LandName == "Snout", :, ...
        ((t_ix-1).*(mad.TrialLen-1) + 1):(t_ix.*(mad.TrialLen-1)));
    for f_ix = 1:(mad.TrialLen-1)
        mad.SupMotor.SOD((t_ix-1).*(mad.TrialLen-1) + f_ix) = ...
            min(sqrt(sum((snt(:, :, f_ix) - mad.Obj.Mesh{c_}).^2, 2)));
        mad.Motor.SOD((t_ix-1).*(mad.TrialLen-1) + f_ix) = ...
            f(min(sqrt(sum((snt(:, :, f_ix) - mad.Obj.Mesh{c_}).^2, 2))));
    end
    c_ = c_+1;
end
close all
end

