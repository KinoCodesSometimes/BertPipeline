function [ArgValues] = F_VararginSelection(OpArgs, ...
    ValsExpTypes, ValsOptions, ValsDefault, varargin)
%F_VARARGINSELECTION Summary of this function goes here
%   Detailed explanation goes here
%% Storage of variables
    ArgLoco = repelem(1, length(OpArgs)); % Order of specified variables
    % Storage of the specified options as a dictionary for ease of use
    % ValsExpTypes = dictionary(OpArgs.', ValsExpTypes);
    ValType = repelem("", length(OpArgs));
    ExpType = repelem("", length(OpArgs));

    %% Internal dictionaries and data
    MultipleArgs = dictionary('string', 'list', ...
        'double', 'matrix', 'logical', 'logical');

    %% Identifying errors
    % If there are optional arguments
    if ~isempty(varargin)

    % Checking correct number of arguments
        if rem(length(varargin), 2)~=0
            error('Incorrect number of input arguments.')
        end

    % Reading the inputs
        KeyWords = string(varargin(1:2:end));

    % Verifying that the argument names are correct
        if sum(~contains(KeyWords, OpArgs))> 0
            error(strcat('Unrecognized input ', ...
                string(KeyWords(find(contains(KeyWords, OpArgs)== 0, 1)))))
        end
        
    %% Determining the location of each argument
        % Counter to determine location of argument
        c = 2;

        % Iterating per argument name
        for Word = KeyWords

            % And storing the answer location
            ArgLoco(OpArgs == Word) = c;
            c = c+2;
        end
        
        % Extracting user answers according to input order
        ArgValues = varargin(ArgLoco);
        

        % Replacing non-defined arguments with the default value
        ArgValues(ArgLoco == 1) = ValsDefault(ArgLoco == 1);

    %% Determining the type of variable that the user inputed
        c = 1; % Counter function

        % Looping through each argument
        for Val = ArgValues
            
            % Saving the type
            Type(c) = string(class(Val{:}));
            if sum(size(Val{:})) > 2

                % Updating given dimensions of input
                Type(c) = MultipleArgs(Type(c));
            end

            % Verifying that matches the expected value
            if sum(ValsExpTypes{c} == Type(c)) == 0

                % Generating error message
                if sum(size(ValsExpTypes{c})) > 2
                    expected = join(ValsExpTypes{c}, " or ");
                else
                    expected = ValsExpTypes{c};
                end

                % Notifying the user

                error(strcat("Invalid data type for ", OpArgs(c), ...
                    ". Expected ", string(expected), "."))
                
            end

            % Updating the counter
            c = c+1;
            
        end

    %% Now verifying that the set conditions are met
        c = 1; % Counter function

        % Iterating per given values
        for Val = ArgValues

            % If there are some restrictions
            if ~isempty(ValsOptions{c})
                if Type{c} == "string"
                     if sum(ValsOptions{c} == Val{:}) == 0
                         error(strcat("Invalid string for ", ...
                             OpArgs{c}))
                     end
                elseif Type{c} == "double"
                    if Val{:}<ValsOptions{c}(1) | Val{:}>ValsOptions{c}(2)
                        error(strcat("Invalid value for ", ...
                             OpArgs{c}, ". Value must be between ", ...
                             string(ValsOptions{c}(1)), " and ", ...
                             string(ValsOptions{c}(2)), "."))
                    end
                end
            end

            c = c+1; % Updating the counter
        end

        % Converting to dictionary format for ease of use
        ArgValues = dictionary(OpArgs, ArgValues);

        
    else

        ArgValues = dictionary(OpArgs, ValsDefault);
    end
end
