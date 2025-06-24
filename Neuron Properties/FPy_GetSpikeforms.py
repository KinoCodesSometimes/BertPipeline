# Spike interface packages
import spikeinterface.extractors as se # Reading kilosort output
from spikeinterface import extract_waveforms # Extracts single spikes from raw
from probeinterface import Probe, ProbeGroup
from spikeinterface.preprocessing import highpass_filter # High pass for cleaning the raw

# Management packages
import numpy as np
from scipy.io import loadmat
import sys

# Reading user inputs
sorting_folder = sys.argv[1] # Kilosort output file
binary_file = sys.argv[2]  # Concatenated file
ProbePath = sys.argv[3]  # Chan map generated for kilosorting
SavePath = sys.argv[4]  # Save location
# Extracting channel map and coords
mat = loadmat(ProbePath) # Loading ChanMap .mat file

# Extracting xy
xcoords = mat['xcoords'].squeeze()
ycoords = mat['ycoords'].squeeze()
positions = np.column_stack((xcoords, ycoords))
n_channels = positions.shape[0]

# Setting the probe parameters
probe = Probe(ndim=2, si_units='um')
probe.set_contacts(
    positions=positions.tolist(),  # shape (n_channels, 2)
    shapes='rect',
    shape_params={'width': 12.0, 'height': 12.0}
)

# Adding information about the shanks (JRPP - Adapt fopr 1.0s)
if 'kcoords' in mat:
    shank_ids = mat['kcoords'].squeeze().astype(int)
    probe.annotate(shank_ids=shank_ids)


# Setting recording parameters
recording = se.read_binary(
    file_paths=[binary_file],      
    sampling_frequency=30000, # Unlikely to change, could be an additional parameter
    num_channels=384,
    dtype='int16',
    time_axis=0
)

probe.set_device_channel_indices(np.arange(n_channels))
pg = ProbeGroup()
pg.add_probe(probe)
recording = recording.set_probe(probe)

sorting = se.read_kilosort(sorting_folder)

# UI
print("     Extracting the waveforms. This may take a while")


# Extracting raw waveforms
waveform_extractor = extract_waveforms( 
    recording = highpass_filter(recording, freq_min=300), # Highpass
    sorting = sorting, # Reading kilosort output
    folder = SavePath, # Output folder
    ms_before = 1.0, 
    ms_after = 2.0,
    max_spikes_per_unit = 500,
)

# Extracting the mean waveform for each unit
MeanWaves = []
for n_ix in sorting.get_unit_ids():
    unit_waveforms = waveform_extractor.get_waveforms(n_ix)
    mean_waveform = unit_waveforms.mean(axis=0)
    best_channel = np.abs(mean_waveform).max(axis=0).argmax()
    MeanWaves.append(mean_waveform[:, best_channel])
    
MeanWaves = np.array(MeanWaves)


# Saving the output
np.save(SavePath + "/MeanWaves.npy", MeanWaves)
np.save(SavePath + "/IX.npy", sorting.get_unit_ids())