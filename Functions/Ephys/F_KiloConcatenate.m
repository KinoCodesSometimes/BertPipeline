function [ConcatenatedFolders, writer_file, chan_map] = ...
    F_KiloConcatenate(varargin)
% F_KILOCONCATENATE Concatenates the selected neuropixel folders before
% kilosorting.
% JRPP - Petersen Lab

% Determining file specifications
% ispc for later

%% Specifying task variables
    % Re-write to account for the different types of neuropixel
datpath = [strcat("\Record Node 101\experiment1\recording1\continuous", ...
    "\Neuropix-PXI-100.ProbeA-AP\continuous.dat"); ...
    strcat("\Record Node 101\experiment1\recording1\continuous", ...
    "\Neuropix-PXI-100.ProbeA\continuous.dat"); ...
    strcat("\Record Node 122\experiment1\recording1\continuous\", ...
    "Neuropix-PXI-100.0\continuous.dat")];

%% Identifying all folders

% If a folder was inputed as a source
if nargin == 0
    catdir = uigetdir('','Select recordings folder');
else
    catdir = varargin{1};
end

% Reading the folder
catfolders = string({dir(catdir).name});
catfolders = catfolders(3:end);

% Excluding dat or mat files
catfolders(contains(catfolders, ".mat") | ...
    contains(catfolders, ".dat")) = [];
catfolders = cellstr(catfolders);

% Re-ordering the data
trial_ix = cell2mat(cellfun(@(x) F_GetTrialNum(x), catfolders, ...
    'UniformOutput', false));
[~, order] = sort(trial_ix, 2, "ascend");
catfolders = {catfolders{order}};


%% Extracting all channel maps
% Gathering 
    elect_xy.x = {};        elect_xy.y = {};
    for f_ix = 1:length(catfolders)

        % Determining version of open ephys
        if isfile(catdir +  "\" + catfolders{f_ix} + ...
                "\Record Node 101\settings.xml")
            data = readstruct(catdir +  "\" + catfolders{f_ix} + ...
                "\Record Node 101\settings.xml");
            
        elseif isfile(catdir +  "\" + catfolders{f_ix} + ...
                "\Record Node 122\settings.xml")
            data = readstruct(catdir +  "\" + catfolders{f_ix} + ...
                "\Record Node 122\settings.xml");
        else
            error("No settings found for file " + f_ix)
        end

        % Extracting and storing the xy coords
        elect_xy.x{f_ix} = cell2mat(struct2cell(...
            data.SIGNALCHAIN(1).PROCESSOR(1).EDITOR.NP_PROBE.ELECTRODE_XPOS));
        elect_xy.y{f_ix} = cell2mat(struct2cell(...
            data.SIGNALCHAIN(1).PROCESSOR(1).EDITOR.NP_PROBE.ELECTRODE_YPOS));

    end

% Determining that all the channel maps are the same
    if all(cell2mat(elect_xy.x) == cell2mat(elect_xy.x(1)), 'all') ~= 1
        warning("WARNING: Not all channel maps are the same for" + ...
            catdir)
    end

% Generating and saving channel maps(Section by LG)
    name = ...
        char(data.SIGNALCHAIN(1).PROCESSOR(1).EDITOR.NP_PROBE.electrodeConfigurationPresetAttribute); % produces char rather than string
    x_pos_str = ...
        data.SIGNALCHAIN(1).PROCESSOR(1).EDITOR.NP_PROBE.ELECTRODE_XPOS;
    x_pos_chann = fieldnames(x_pos_str);
    pattern = '\d+';
    in= regexp(x_pos_chann,pattern,'match');
    chanMap0ind = cellfun(@str2num,[in{:}])'; % chanMap0ind should start at 0
    chanMap = chanMap0ind+1; %chanMap should start at 1
    xcoords = cell2mat(struct2cell(x_pos_str)); % extracts correctly
    connected = true([384,1]);
    kcoords = double(ones([384,1])); % same as NP2
    y_pos_str = data.SIGNALCHAIN(1).PROCESSOR(1).EDITOR.NP_PROBE.ELECTRODE_YPOS;
    ycoords = cell2mat(struct2cell(y_pos_str)); % extracts correctly
    
    % Saving
    save(catdir + "\ChanMap", ...
        'chanMap','xcoords','ycoords','chanMap0ind', ...
        'connected','kcoords','name')
    chan_map = catdir + "\ChanMap.mat";

%% Concatenating
% Saving parms
    writer_file = "Concatenated.dat";

% Generating output
    fid_write = fopen(strcat(catdir, "\Concatenated.dat"), 'w');
    ConcatenatedFolders = string(catfolders);
    



% Notifying user
wb = waitbar(0, "Concatenating files");
% Iterating per trial
for f_ix = 1:length(catfolders)
    waitbar(f_ix/length(catfolders))
    catfolders{f_ix}
    % Identifying the files
    if isfile(strcat(catdir, '\', catfolders{f_ix}, datpath(1)))
        fid_read = ...
            fopen(strcat(catdir, '\', catfolders{f_ix}, datpath(1)));

    elseif isfile(strcat(catdir, '\', catfolders{f_ix}, datpath(2)))
        fid_read = ...
            fopen(strcat(catdir, '\', catfolders{f_ix}, datpath(2)));

    elseif isfile(strcat(catdir, '\', catfolders{f_ix}, datpath(3)))
        fid_read = ...
            fopen(strcat(catdir, '\', catfolders{f_ix}, datpath(3)));
    else
        ConcatenatedFolders = ...
            ConcatenatedFolders(ConcatenatedFolders == catfolders{f_ix});
        fprintf('%s\n', ...
            "No data file found, please select dat file manually")
    end

    fwrite(fid_write, fread(fid_read, '*int16'), 'int16');
    

end
close(wb)
wb = waitbar(1, "U go get them files kilosorted gurl", "Color", "#F14CBF");
pause(.1)
close(wb)
fclose(fid_write)
ConcatenatedFolders = catdir + "\" + ConcatenatedFolders;
end



function a = F_GetTrialNum(TrialName)
    a = split(string(TrialName), " ");
    a = a{2} - '0'; % Selecting the string and excluding non-digits
    a(a<0 | a>9) = [];
    if length(a) > 1
        a = 10*a(1) + a(2);
    end
end