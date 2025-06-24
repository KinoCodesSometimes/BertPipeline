function [mad] = ...
    F_DeconcatEphys(mad)
% F_DECONCATKILOSORTRESULTS 
% After concatenating your data and kilosorting it, this code splits the 
% kilosort output into the single recordings and corrects the timestamps.
% Adapted from Luka's Piezo_ION code.

% Loading all required functions 
% addpath(genpath(['C:\Users\JoaquinRusco\Documents\Joaquin - Local PC', ...
%     '\Matlab\AllFunctions'])) % JRPP - Avoid local functions

% Getting the results path
result_path = char(mad.Ephys.KiloPath);


% Loading the spikes, spike templates and neurons
    spikes_time = readNPY([result_path, '\spike_times.npy']);
    spike_t = readNPY([result_path, '\spike_templates.npy']);
    temp_amps = readNPY([result_path, '\amplitudes.npy']);
    neurons = readNPY([result_path, '\spike_clusters.npy']);
        temps = readNPY([result_path, '\templates.npy']);
    spike_times = ...
        double(spikes_time)/mad.RunParams.EphysSampleRate;

% Plotting the waveforms - JRPP - Work in progress
    % F_PlotSpikeTemplates(neurons, temps, spikes_time, ...
    %     mad.Ephys.Concatenated, "Savename", "test")%mad.RunParams.FigSaveLoc + "\Spikeforms")

% Importing the kilosort whitening filter
    winv = readNPY([result_path, '\whitening_mat.npy']);

% Importing the channel map and getting the template depths
    if exist([result_path, '\rez.mat'])
        load([result_path, '\rez.mat']); % As Rez
        [~, ~, templateDepths, ~, ~, ~, waveforms] = ...
            templatePositionsAmplitudes(temps, winv, rez.ycoords, ...
            spike_t, temp_amps);
    else % Kilosort 4
        chan_pos = readNPY([result_path, '\channel_positions.npy']);
        [~, ~, templateDepths, ~, ~, ~, waveforms] = ...
            templatePositionsAmplitudes(temps, winv, chan_pos(:, 2), ...
            spike_t, temp_amps);
    end
    spikes = cell(1,numel(templateDepths))';

mad.Neurons.Waveforms = waveforms;
mad.Neurons.Depths = templateDepths;
% Not fully sure what this does
for template_id = 0:(numel(templateDepths)-1)
    idx = neurons==template_id; %get indicies when selected neuron is spiking
    spikes{template_id + 1} = spike_times(idx); % spike times of selected neuron
    %disp(["extracting spikes from individual neurons; Current neuron: " + num2str(template_id)]);
end % end template_id loop

%% Loading the timestamp data for each session
% Setting the possible paths for the different versions of the neuropixel
event_paths = ...
    {['\Record Node 122\experiment1\recording1\events', ...
        '\Neuropix-PXI-100.0\TTL_1\'], ...
    ['\Record Node 101\experiment1\recording1\events', ...
        '\Neuropix-PXI-100.ProbeA-AP\TTL\'], ...
    ['\Record Node 101\experiment1\recording1\events', ...
        '\Neuropix-PXI-100.ProbeA\TTL\']};
cont_paths = ...
    {['\Record Node 122\experiment1\recording1\continuous\', ...
        'Neuropix-PXI-100.0\'], ...
    ['\Record Node 101\experiment1\recording1\continuous\', ...
        'Neuropix-PXI-100.ProbeA-AP\'], ...
    ['\Record Node 101\experiment1\recording1\continuous\', ...
        'Neuropix-PXI-100.ProbeA\']};

nidaq_paths = ...
    {['\Record Node 122\experiment1\recording1\continuous\', ...
        'NI-DAQmx-107.PXIe-6341\continuous.dat'], ...
    ['\Record Node 101\experiment1\recording1\continuous', ...
        '\NI-DAQmx-107.PXIe-6341\continuous.dat'], ...
    ['\Record Node 101\experiment1\recording1\continuous\', ...
        'NI-DAQmx-107.PXIe-6341\continuous.dat']};

% Storage
mad.Timestamps = [];
    mad.Timestamps.SessionPath = mad.Ephys.CatFolders;
    mad.Timestamps.Events = {};
    mad.Timestamps.Continuous = {};
    mad.Timestamps.State = {};
    mad.Timestamps.Sync = {};
    mad.Timestamps.NiDaq = {};

% Iterating per session - JRPP - Simplify code by turning this into a
% function
for sess_path = mad.Ephys.CatFolders
    % Accounting for neuropxl version
    if isfile(strcat(sess_path, event_paths{1}, "timestamps.npy"))

        % Timestamps
        mad.Timestamps.Events{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, event_paths{1}, ...
            "timestamps.npy")))./mad.RunParams.EphysSampleRate;

        % Continuous
        mad.Timestamps.Continuous{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, cont_paths{1}, ...
            "timestamps.npy")))./mad.RunParams.EphysSampleRate;

        % Pulse state
        mad.Timestamps.State{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, event_paths{1}, ...
            "full_words.npy")))./mad.RunParams.EphysSampleRate;

        % Loading NiDaq data
        [Timestamp, States] = ...
            F_FindNidaqTriggers(strcat(sess_path, nidaq_paths{1}), ...
            "FigureSavePath", ...
                mad.RunParams.FigSaveLoc + "\NiDaqTriggers.pdf",...
            "Channels", 2);

        % Writing onto MAD
        mad.Timestamps.NiDaq{mad.Ephys.CatFolders == sess_path}.Timestamp = ...
            cellfun(@(x) ...
            mad.Timestamps.Continuous{mad.Ephys.CatFolders == sess_path}(x), ...
            Timestamp, 'UniformOutput', false)
        mad.Timestamps.NiDaq{mad.Ephys.CatFolders == sess_path}.State = ...
            States;

            
    elseif isfile(strcat(sess_path, event_paths{2}, "sample_numbers.npy"))

        % Timestamps
        mad.Timestamps.Events{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, event_paths{2}, ...
            "sample_numbers.npy")))./mad.RunParams.EphysSampleRate;

        % Continuous
        mad.Timestamps.Continuous{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, cont_paths{2}, ...
            "sample_numbers.npy")))./mad.RunParams.EphysSampleRate;

        % Pulse state
        mad.Timestamps.State{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, event_paths{2}, ...
            "full_words.npy")))./mad.RunParams.EphysSampleRate;

        % Reading sync file
        Sync_path = split(cont_paths{2}, "continuous");
        Sync_file = importdata(strcat(sess_path, Sync_path{1}, ...
            "sync_messages.txt"), 'r');
        Sync_data = split(Sync_file{2}, "Hz: ");
        mad.Timestamps.Sync{mad.Ephys.CatFolders == sess_path} = ...
            str2double(Sync_data{2})./mad.RunParams.EphysSampleRate;

        % Loading NiDaq data
        [Timestamp, States] = ...
            F_FindNidaqTriggers(strcat(sess_path, nidaq_paths{2}), ...
            "FigureSavePath", ...
                mad.RunParams.FigSaveLoc + "\NiDaqTriggers.pdf",...
            "Channels", 2);
        size(Timestamp)
        % Writing onto MAD
        mad.Timestamps.NiDaq{mad.Ephys.CatFolders == sess_path}.Timestamp = ...
            cellfun(@(x) ...
            mad.Timestamps.Continuous{mad.Ephys.CatFolders == sess_path}(x), ...
            Timestamp, 'UniformOutput', false)
        mad.Timestamps.NiDaq{mad.Ephys.CatFolders == sess_path}.State = ...
            States;


    elseif isfile(strcat(sess_path, event_paths{3}, "sample_numbers.npy"))

        % Timestamps
        mad.Timestamps.Events{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, event_paths{3}, ...
            "sample_numbers.npy")))./mad.RunParams.EphysSampleRate;

        % Continuous
        mad.Timestamps.Continuous{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, cont_paths{3}, ...
            "sample_numbers.npy")))./mad.RunParams.EphysSampleRate;

        % Pulse state
        mad.Timestamps.State{mad.Ephys.CatFolders == sess_path} = ...
            double(readNPY(strcat(sess_path, event_paths{3}, ...
            "full_words.npy")))./mad.RunParams.EphysSampleRate;

        % Reading sync file
        Sync_path = split(cont_paths{2}, "continuous");
        Sync_file = importdata(strcat(sess_path, Sync_path{1}, ...
            "sync_messages.txt"), 'r');
        Sync_data = split(Sync_file{2}, "Hz: ");
        mad.Timestamps.Sync{mad.Ephys.CatFolders == sess_path} = ...
            str2double(Sync_data{2})./mad.RunParams.EphysSampleRate;

        % Loading NiDaq data
        if mad.RunParams.LoadNidaq == true
            fr = fopen(strcat(sess_path, nidaq_paths{1}), "r");
            nidaq = double(reshape(fread(fr, '*int16'), 8, [])); % Reading data
    
            % Loading NiDaq data
            [Timestamp, States] = ...
                F_FindNidaqTriggers(strcat(sess_path, nidaq_paths{3}), ...
                "FigureSavePath", ...
                    mad.RunParams.FigSaveLoc + "\NiDaqTriggers.pdf",...
                "Channels", 2);
    
            % Writing onto MAD
            mad.Timestamps.NiDaq{mad.Ephys.CatFolders == sess_path}.Timestamp = ...
                cellfun(@(x) ...
                mad.Timestamps.Continuous{mad.Ephys.CatFolders == sess_path}(x), ...
                Timestamp, 'UniformOutput', false)
            mad.Timestamps.NiDaq{mad.Ephys.CatFolders == sess_path}.State = ...
                States;
        end
    else
        error("Timestamps files not found. Verify path.")
    end
end

%% Raster plot initial visualisation - Pre deconcatenation
for n_ix = 1:length(spikes)
    scatter(spikes{n_ix}, repelem(n_ix, length(spikes{n_ix})), 'filled', 'k')
    hold on
end

%% Deconcatenation boundary estimation and neuronal segmentation

% Storage for the boundaries
mad.Neurons.Spikes = [];
prev_t_end = 0;

for sess_ix = 1:length(mad.Ephys.CatFolders)
    sess_ix
    start_of_session = mad.Timestamps.Continuous{sess_ix}(1);

    % Event and continuous event correction
    mad.Timestamps.Events{sess_ix} = ...
        mad.Timestamps.Events{sess_ix} - start_of_session;
    mad.Timestamps.Continuous{sess_ix} = ...
        mad.Timestamps.Continuous{sess_ix} - start_of_session;
    if mad.RunParams.LoadNidaq == true
        mad.Timestamps.NiDaq{sess_ix}.Timestamp = ...
            cellfun(@(x) x - start_of_session, ...
            mad.Timestamps.NiDaq{sess_ix}.Timestamp, 'UniformOutput', false);
    end
    
    % Neuron segmentation given the boundaries
    for neuron_ix = 1:length(spikes)

        % Identifying spikes between the two boundaries
        mad.Neurons.Spikes{sess_ix}{neuron_ix} = ...
            spikes{neuron_ix}(spikes{neuron_ix} > prev_t_end & ...
            spikes{neuron_ix} < ...
            (prev_t_end+mad.Timestamps.Continuous{sess_ix}(end))) - ...
            (prev_t_end);
    end

    % Visualising the boundaries
    xline(prev_t_end + mad.Timestamps.Continuous{sess_ix}(end), ...
        "Color", 'r', "LineWidth", 2)
    try
        xline(prev_t_end + mad.Timestamps.Events{sess_ix}, "Color", 'b', ...
             "LineWidth", 1)
    catch
        warn = split(mad.Timestamps.SessionPath{sess_ix}, "\");

        fprintf("%s\n", ...
            "<strong> WARNING! No triggers detected in </strong>" + ...
            warn(end))

    end


    % Updating the boundary between trials
    prev_t_end = prev_t_end+mad.Timestamps.Continuous{sess_ix}(end);

end
clear prec_t_end sess_ix
hold off

xlabel("Frame")
ylabel("Neuron index")

end

