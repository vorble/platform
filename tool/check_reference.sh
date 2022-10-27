#!/bin/bash

set -e

./tool/generate_reference.py > REFERENCE.md

if ( git status --porcelain | grep '^ M REFERENCE\.md$' ); then
  echo 'REFERENCE.md is out of sync with source material! Please regenerate REFERENCE.md!' 1>&2
  exit 1
fi
