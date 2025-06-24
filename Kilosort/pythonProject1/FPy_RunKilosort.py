print("Called")
from kilosort import run_kilosort
import sys

path_in = sys.argv[1]
path_out = sys.argv[2]
probe_names = sys.argv[3]
settings = {'n_chan_bin': 384}
run_kilosort(filename=path_in,settings=settings, probe_name=probe_names,results_dir=path_out)
