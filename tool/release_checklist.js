#!/usr/bin/env shepherd

// Copyright (C) 2022 Keith "vorble"
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

'use strict'

// These copyrights get bumped on a release. Other file copyrights should be
// bumped with the patch for the change.
task('Bump Copyright Year')
  .step('Bump Copyright Year in COPYRIGHT')
  .step('Bump Copyright Year in vorble/COPYRIGHT')
  .step('Bump Copyright Year in vorble/LICENSE')

task('Bump Version')
  .step('Bump Version in setup.sh')
  .step('Bump Version in README.md')
  .step('Bump Version in REFERENCE.md')
  .step('Bump Version in vorble/README.md')
  .step('Write Release Notes in CHANGELOG.md')

task('Tag and Push')
  .step('Tag Version (v1.0.6 style)')
  .step('Push main to GitHub')
  .step('Push Tag to GitHub')
  .done(exit)
