function [NiDaqTriggers, NiDaqState] = F_FindNidaqTriggers(NiDaqContinuous, ...
    varargin)
    
    % Optional arguments
    ArgValues = F_VararginSelection(...
        ["FigureSavePath", "ITI", "Channels"], ...
        {["string", "logical"], 'double', ["double", "matrix"]}, ...
        {'', '', ''}, ...
        {false, .5, 1:8}, varargin{:});

    % Loading NiDaq data
    fr = fopen(NiDaqContinuous, "r"); 
    nidaq = double(reshape(fread(fr, '*int16'), 8, [])); % Reading data
    
    % Parameters - JRPP - Make it editable in MAD
    exp_iti = ArgValues{"ITI"}; % In seconds
    sr = 30000;    % Sampling rate

    % Storage
    NiDaqTriggers = cell(1, 8);
    NiDaqState = NiDaqTriggers;
    %% Thresholding
    % Transforming parameters to samples
    exp_iti = exp_iti.*sr;


    for ch_ix = ArgValues{"Channels"}% Iterating per NiDaq channel

        % Determining the threshold for the given channel
        med = median(nidaq(ch_ix, :));
        sd = std(nidaq(ch_ix, :));
        ci = norminv(.999).*sd; % Setting the confidence interval
        clear sd
    
        % Binarisation
        trigg = 1 - double((med - ci) < nidaq(ch_ix, :) & ... 
            (med + ci) > nidaq(ch_ix, :));

        % Identifying the stimulation periods
        start_stim = F_SearchNiDaqChanges(trigg, exp_iti);
        end_stim = length(trigg) - ...
            F_SearchNiDaqChanges(flip(trigg), exp_iti) + 1;
    
        if string(class(ArgValues{"FigureSavePath"})) == "string"
            % Vis 1 - Nidaq data + thresholds
            subplot(2, 1, 1)
                plot(nidaq(ch_ix, :))
                hold on
                yline(med + [-1, 1]*ci)
                hold off
            
            % Vis 2 - Samples out of bounds
            subplot(2, 1, 2)
                area(trigg)
    
                xline(start_stim, "Color", 'r', "LineWidth", 3);
                xline(end_stim, "Color", 'g', "LineWidth", 3);

                exportgraphics(gcf, ArgValues{"FigureSavePath"}, ...
                    "ContentType", 'image', "Append", true)
        end
        
        % Merging into a make-shift sample word and timestamp file
        [NiDaqTriggers{ch_ix}, ix] = sort([start_stim, end_stim], ...
            "ascend");
        NiDaqState{ch_ix} = zeros(size(NiDaqTriggers{ch_ix}));
        NiDaqState{ch_ix}(1:length(start_stim)) = 1;
        NiDaqState{ch_ix} = NiDaqState{ch_ix}(ix);
    end
end