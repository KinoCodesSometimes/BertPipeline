function mad = F_CurateNeurons(mad)
%F_CURATENEURONS Summary of this function goes here
%   Detailed explanation goes here

    if mad.RunParams.Curation == "Phy"
        F_CallPhy(mad.Ephys.KiloPath)
    elseif mad.RunParams.Curation == "BombCell"
        mad = F_BombcellCurate(mad)
    elseif mad.RunParams.Curation == "Kilosort"
        % JRPP - Scrape and read output from kilosort. 
    else
        error("The speciied method of curation was not recognised.")
    end
end

