function F_BatchReadPhy(mad)
    % Reading the phy output
    t = readtable(mad.Ephys.KiloPath + "\cluster_info.tsv", ...
        "FileType","text",'Delimiter', '\t');
    
    % Error if the session has not been curated
    if sum(string(t.Properties.VariableNames) == "group") ~= 1
        error("This trial has not been curated with Phy.")
    end
    
    % Assigning
    mad.Neurons.GoodUnits_Phy = (string(t.group) == "good");
    
    % Saving
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
end

