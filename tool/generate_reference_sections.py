#!/usr/bin/env python3

import os
import pathlib
import sys


os.chdir(os.path.dirname(sys.argv[0]))
os.chdir('..')

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

print('# Environment')
print()
for fname in sorted(os.listdir('env')):
    conditionally_generate_env_reference(fname, os.path.join('env', fname))
print()

print('# Options')
print()
for fname in sorted(os.listdir('option')):
    conditionally_generate_env_reference(fname, os.path.join('option', fname))
print()
