#!/usr/bin/python

import sys; sys.dont_write_bytecode = True
import os
import stat

filename = "/home/loreto/__loreto"
mode = os.stat(filename).st_mode
ro_mask = 0o777 ^ (stat.S_IWRITE | stat.S_IWGRP | stat.S_IWOTH)
wr_mask = 0o777 | (stat.S_IWRITE | stat.S_IWGRP | stat.S_IWOTH)
os.chmod(filename, mode & wr_mask)