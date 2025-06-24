function [x_] = F_SplitTrials(x, TrialLen)
    x_ = cell(1, size(x, 2)/TrialLen);
    for t_ix = 1:(size(x, 2)/TrialLen)
        x_{t_ix} = x(:, (1 + (t_ix-1)*TrialLen):(TrialLen*t_ix));
    end
end

