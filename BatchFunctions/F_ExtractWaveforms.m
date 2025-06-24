function [mad] = F_ExtractWaveforms(mad)
    mad.Envs.SpikeInterface = "C:\Users\JoaquinRusco\anaconda3\envs\SpikeInter\python.exe";
    mad = F_GetMeanWaveforms(mad);
    save(mad.RunParams.SaveLoc + "\mad.mat", "mad")
end