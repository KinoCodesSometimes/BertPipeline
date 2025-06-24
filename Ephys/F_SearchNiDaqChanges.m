function [tone_start] = F_SearchNiDaqChanges(NiDaq, exp_iti)
%F_SEARCHAUDIOTRIGGERS Summary of this function goes here
%   Detailed explanation goes here

% Storage
tone_start = [];
continue_search = true; % While loop termination
last_start = 1; % Storage of last tone

% Searching for the start of triggers
    while continue_search
        f = find(NiDaq(last_start:end) == 1, 1) + last_start;
        last_start = f + exp_iti;

        % Storing
        tone_start = [tone_start, f-1]; %#ok<AGROW>

        if last_start > length(NiDaq)
            % Checking we haven't reached the end of the recording
            continue_search = false; % Killing the while loop.
        end

        if isempty(f)
            continue_search = false;
        end
    end
end

