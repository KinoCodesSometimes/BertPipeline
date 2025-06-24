function [out] = F_Derivate(in)
%F_DERIVATE Summary of this function goes here
%   Detailed explanation goes here

out = cell(size(in));
for t_ix = 1:length(in)
    out{t_ix} = [zeros(size(in{t_ix}, 1), 1), diff(in{t_ix}, [], 2)];
end
    
end

