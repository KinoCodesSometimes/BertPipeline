from contextlib import chdir
import sys


# Changing the path
with chdir(sys.argv[1]):
    from phy.apps.template import template_gui
    template_gui("params.py")

