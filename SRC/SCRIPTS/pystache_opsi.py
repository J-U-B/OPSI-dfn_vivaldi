#! /usr/bin/env python3
#---------------------------------------------------------------------
# Slightly modified pystache to handle the extension
# issue for the template files
#
# Jens Boettge <boettge@mpi-halle.mpg.de>	2017-08-28 13:19:57 +0200
#---------------------------------------------------------------------
__requires__ = 'pystache'
import sys
from pkg_resources import load_entry_point
import pystache.defaults as defaults


if __name__ == '__main__':
	defaults.TEMPLATE_EXTENSION=False
	sys.exit(
		load_entry_point('pystache', 'console_scripts', 'pystache')()
	)
