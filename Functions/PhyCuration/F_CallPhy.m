function F_CallPhy(KiloPath)

% Creating the conda environment
pyenv(Version = "C:\Users\JoaquinRusco\anaconda3\envs\phy2\python.exe");

pyrunfile(pwd + "\Functions\PhyCuration\FPy_CurateNeurons.py '" + ...
        KiloPath + "'")

end

