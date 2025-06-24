function F_ConcatenateEphys(varargin)
% Setting parms
    opts = {'\Record Node 122\experiment1\recording1\continuous\Neuropix-PXI-100.0\continuous.dat', ...
        '\Record Node 101\experiment1\recording1\continuous\Neuropix-PXI-100.ProbeA\continuous.dat', ...
        '\Record Node 101\experiment1\recording1\continuous\Neuropix-PXI-100.ProbeA-AP\continuous.dat'};
            % Add path to continuous in opts list to include more versions of
            % open ephys.

% User input
    foldercat = uigetdir('', "Select ephys folder"); % Determining location
    filter = {strcat(foldercat, '.dat')}; % Creating the output
    [writer_file, writer_path] = uiputfile(filter, ...
        'Where should the file be saved');
    fid_write = fopen([writer_path, writer_file], 'w'); % Creating the file
    fprintf("Identifying and concatenating Ephys files.\n") % UI


% Identifying all relevant files
    % Identifying the 
    folder = dir(foldercat); % Getting contents
    subfolders = {folder([folder.isdir]).name}; % Selecting subfolders
    subfolders = subfolders(3:end); % Removing empty objects

    % Finding correctly named files
    kilosort_files = ...
        subfolders(~cellfun(@isempty, regexp(subfolders, 'Trial|trial')));
    clear folder subfolders

    % Sorting the files
    num = NaN(1, length(kilosort_files)); % Storage
    for t_ix = 1:length(kilosort_files)
        match = ...
            regexp(kilosort_files{t_ix}, 'Trial (\d+)', 'tokens', 'once');
        num(t_ix) = str2num(match{:});
    end
    fprintf("   " + sum(~isnan(num)) + " Ephys files identified.\n") % UI
    fprintf("   Concatenating.\n") % UI
 

% Concatenating
    wb = waitbar(0, "Concatenating ephys."); % UI
    concatenated_trials = cell(1, length(num)); % Storage
    trials = sort(trial_int);
    for f_ix = 1:length(num) % Iterating per file in order
        waitbar(f_ix);
        idx = trials(f_ix) == num; % Identifying the correct file
        concatenated_trials{f_ix} = kilosort_files{idx};

        catted = false; % True when it has been concatenated

        % Identifying the relevant files
        for o = 1:length(opts)

            if catted == false && ...  % Checking that file exists
                    isfile([foldercat, '\', kilosort_files{idx}, opts{o}])
                fid_read = ...  % Reading the file
                    fopen([foldercat, '\', kilosort_files{idx}, opts{o}]);
                catted = true;
            end
        end

        fwrite(fid_write, fread(fid_read, '*int16'), 'int16'); % Writing
        fclose(fid_read);

    end
    close wb
    fclose(fid_write);

end

