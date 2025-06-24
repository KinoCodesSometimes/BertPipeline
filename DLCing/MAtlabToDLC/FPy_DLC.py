
import deeplabcut
import sys
import logging
logging.basicConfig(level=logging.DEBUG)
deeplabcut.analyze_videos(sys.argv[1], sys.argv[2], save_as_csv=True) # , shuffle = sys.argv[3]
