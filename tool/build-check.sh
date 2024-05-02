#!/bin/bash
#
# Ensure that "pub run build_runner build" was run and committed.
#

# Fast fail the script on failures.
set -x -e -o pipefail

dart pub run build_runner build --delete-conflicting-outputs
git status
git add .
git diff-index --quiet HEAD
