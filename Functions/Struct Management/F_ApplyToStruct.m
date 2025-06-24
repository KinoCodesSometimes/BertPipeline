function [r] = F_ApplyToStruct(funHandle, SourceStruct, TargetFields, ...
    varargin)
%F_ Summary of this function goes here
%   Detailed explanation goes here



%% Optional argument processing
AddArgs = ["Annex", "Prefix", "Sufix"];
ArgValues = F_VararginSelection(AddArgs, ...
    {'logical', 'string', 'string'}, ...
    {'', '', ''}, ...
    {false, "", ""}, varargin{:});

%% Main
if ArgValues{"Annex"} == false
    r = [];
else
    r = SourceStruct;
    if ArgValues{"Prefix"} == "" & ArgValues{"Sufix"} == "" %#ok<AND2>
        ArgValues{"Sufix"} = "v2";
    end
end

source_fields = string(fieldnames(SourceStruct)).'; % Available fields
if ~isempty(TargetFields)   % If concrete fields have been specified
    for f = TargetFields    % Iterating per field
        if sum(f == source_fields) == 0 % Error
            error(f + " was not recognised as a valid fieldname in " + ...
                "the source struct")
        end
        r.(ArgValues{"Prefix"} + f + ArgValues{"Sufix"}) = funHandle(SourceStruct.(f));    % Applying to each field
    end
else    % Apply to all fields
    for f = source_fields
        r.(ArgValues{"Prefix"} + f + ArgValues{"Sufix"}) = ...
            funHandle(SourceStruct.(f));    % Applying to each field
    end
end

