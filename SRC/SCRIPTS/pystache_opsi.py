#! /usr/bin/env python
# -*- coding: utf8 -*-
#---------------------------------------------------------------------
# Slightly modified pystache to handle the extension
# issue for the template files
#
# Jens Boettge <boettge@mpi-halle.mpg.de>	2019-07-08 07:11:11 +0200
#---------------------------------------------------------------------
__requires__ = 'pystache>=0.5.4'
import sys
import codecs
#import locale
from pkg_resources import load_entry_point
import pystache.defaults as defaults


if __name__ == '__main__':
	#sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)
	sys.stdout = codecs.getwriter('utf-8')(sys.stdout)
	#...or call with environment:
	# 	PYTHONIOENCODING=utf8
	defaults.TEMPLATE_EXTENSION = False
	defaults.STRING_ENCODING    = 'utf-8'
	defaults.FILE_ENCODING      = 'utf-8'
	sys.exit(
		load_entry_point('pystache', 'console_scripts', 'pystache')()
	)
