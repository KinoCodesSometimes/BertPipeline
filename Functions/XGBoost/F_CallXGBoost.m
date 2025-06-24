function F_CallXGBoost(file, outpath)
terminate(pyenv)

pyrunfile(pwd + "\Functions\XGBoost\pythonProject2\FPy - XGBoost.py '" + ...
        file + "' '" + outpath + "'")
end

