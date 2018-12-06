#!/usr/bin/env python

import ConfigParser
import sys

cp = ConfigParser.ConfigParser()

commands = {
    2: lambda: cp.sections(),
    3: lambda: cp.items(sys.argv[2]),
    4: lambda: cp.get(sys.argv[2], sys.argv[3])
}

if len(sys.argv) > 1:
    cp.readfp(open(sys.argv[1]))
    print(commands[len(sys.argv)]())
else:
    print('Usage: ' + sys.argv[0] + ' FILENAME [SECTION [OPTION]]')
