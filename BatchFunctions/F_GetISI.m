function [ITIs] = F_GetISI(mad)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
bins = -0.025:.0005:0.025;
ITIs = zeros(length(mad.Neurons.Spikes), length(bins)-1);

for n_ix = 1:length(mad.Neurons.Spikes{1})
    itis = cellfun(@(x) GetITIs(x), cellfun(...
        @(x) x{n_ix}, mad.Neurons.Spikes, 'UniformOutput', false), ...
        'UniformOutput', false);
    empty = cellfun(@isempty, itis);
    
    itis = cat(1, itis{empty == 0});
    ITIs(n_ix, :) = histcounts(itis, bins);
end
end

function itis = GetITIs(x)
    if length(x) > 100
        seg = floor(length(x)./100);
        itis = [];
    
        % Segmenting the data and computing the iti for autocorr
        for s_ix = 1:seg
            itis = [itis; reshape(x(((s_ix-1).*100 + 1):(s_ix.*100)) - ...
                x(((s_ix-1).*100 + 1):(s_ix.*100)).', [], 1)];
            size(itis);
        end
    
        % Calculating the inter-trial intervals
        itis = [itis; reshape(x((seg.*100):end) - x((seg.*100):end).', [], 1)];
        itis(itis == 0) = [];
    else
        itis = reshape(x - x.', [], 1);
        itis(itis == 0) = [];
    end

end