function F_CallKilosort(mad)
% Creating the conda environment
pyenv(Version = mad.Envs.Kilosort, ExecutionMode = 'OutOfProcess');
pyrunfile(pwd + "\Functions\Kilosort\pythonProject1\FPy_RunKilosort.py" + ...
    " '" + mad.Ephys.Concatenated + "' '" + ...
    mad.Ephys.KiloPath + "' '" + mad.Ephys.ChanMap + "'")

 % 
 % 
end

