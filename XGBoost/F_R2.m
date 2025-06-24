function R2 = F_R2(predicted, actual)
R2 = 1 - sum((predicted - actual).^2, 1) ./ ...
    sum(((actual - mean(predicted)).^2), 1);
end

