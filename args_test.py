#!/usr/bin/env python

import sys
import re

f = open("log.txt", "rb")
info = open("info.txt", "ab")
for line in f.readlines():
    if re.search(sys.argv[1], line):
        info.write(line)
        info.close()
        f.close()
