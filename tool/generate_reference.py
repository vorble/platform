#!/usr/bin/env python3

# Copyright (C) 2022 Keith "vorble"
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import sys

os.chdir(os.path.dirname(sys.argv[0]))
os.chdir('..')

def system(command):
    sys.stdout.flush()
    os.system(command)
    sys.stdout.flush()

def despace(text):
    return ' '.join(text.split())

def conditionally_generate_env_reference(opt, fname):
    with open(fname, 'r') as fin:
        doing = 'looking for reference start'
        content = []
        for line in fin:
            line = line.strip()
            if doing == 'looking for reference start':
                if line == '# ' + opt:
                    doing = 'reading reference section'
            elif doing == 'reading reference section':
                if not line or line[0] != '#':
                    doing = 'done'
                else:
                    content.append(line[1:])
    print('* [`{}`]({}) - {}'.format(opt, fname, despace(' '.join(content))))

def cat_without_license(fname):
    with open(fname, 'r') as fin:
        sys.stdout.flush()
        doing = 'printing the start'
        for line in fin:
            if doing == 'printing the start':
                if line.startswith('# Copyright'):
                    doing = 'squelching copyright and license'
                else:
                    sys.stdout.write(line)
            elif doing == 'squelching copyright and license':
                if line == '\n':
                    doing = 'printing the rest'
            elif doing == 'printing the rest':
                sys.stdout.write(line)
        sys.stdout.flush()

print('# Platform Reference')
print()
system('''grep '^\\*Version' README.md''')
print()
print('The following document outlines the API provided by Platform for writing custom loadouts.')
print()
print('## Index')
print()
print('* Environment')
print('* Options')
print('* "Features"')
print('  - Loadouts/Features')
print('  - Hooks')
print('  - "${@}"')
print('* "Includes"')
print('  - Environment/Options')
print('  - Includes')
print()
print('## Environment')
print()
print('The following environment variables are determined by Platform when it runs and are available for use by custom loadouts:')
print()
for fname in sorted(os.listdir('env')):
    conditionally_generate_env_reference(fname, os.path.join('env', fname))
print()
print('## Options')
print()
print('The following options, controllable with environment variables, are available:')
print()
for fname in sorted(os.listdir('option')):
    conditionally_generate_env_reference(fname, os.path.join('option', fname))
print()
print('## "Features"')
print()
print('The general idea of a "feature" applies to several types of scripts used for different purposes, but having similar layout: loadout, feature, and hook scripts. The scripts should perform no action when run with no arguments and, when implemented in POSIX shell (`#!/bin/sh`), should run its arguments received as a command with the syntax `"${@}"`. Any executable file will work as long as it does similar.')
print()
print('### Loadouts/Features')
print()
print('Loadouts and features should be located in a `loadout` or `feature` directory/sub-directory. Here are an example shell script to illustrate the general idea:')
print()
print('```sh')
system('cat loadout/example')
print('```')
print()
print('Each function is optional, so you can skip clutter that you don\'t need.')
print()
print('### Hooks')
print()
print('Hooks should be located in a `hook` directory/sub-directory. Hooks are included automatically when a loadout or feature from your custom loadout is used.')
print()
print('```sh')
system('cat hook/example')
print('```')
print()
print('Each function is optional, so you can skip clutter that you don\'t need.')
print()
print('### "${@}"')
print()
print('For feature scripts implemented in POSIX or similar shells, the script should execute the command `"${@}"` as its final statement to give the Platform tools a way to execute the functions contained within. In addition to the functions outlined in the API, the Platform tools will also send the shell command `type xyz` where `xyz` is the name of one of the functions. The script should exit with a successful code if the function `xyz` is defined.')
print()
print('### Tips')
print()
print('* Variables don\'t propagate out from the feature when they are set, since the feature is a script that is run during the setup process. Use an environment variable or an option instead.')
print()
print('## "Includes"')
print()
print('### Environment/Options')
print()
print('Should be located in a `env` or `option` directory/sub-directory. Environment and option script fragments are included automatically when a loadout or feature from your custom loadout is used. These script fragments must be written in POSIX shell since they are directly sourced into the `platform` script.')
print()
print('Example environment:')
print()
print('```sh')
system('cat vorble/env/VORBLE_VERSION')
print('```')
print()
print('Example option:')
print()
print('```sh')
# uniq just filters out the duplicate blanks after stripping out comments.
system('cat option/DEBUG | grep -v "^#\( \|$\)" | uniq')
print('```')
print()
print('### Includes')
print()
print('Should be located in a `include` directory/sub-directory and must be implemented as a POSIX shell fragment that implement a function. Here is an example include:')
print()
print('```sh')
system('cat include/example')
print('```')
print()
print('The convention is to name the function the same name as the file. The path to include an file is relative to the Platform deployment root, so your custom include file would be included like this:')
print()
print('```sh')
print('. mycustomloadout/include/my_cool_function')
print('```')
