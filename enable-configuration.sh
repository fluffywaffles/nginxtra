#!/bin/bash
if [[ ! $(git status) ]]; then
  >&2 echo "✗ $0 must be invoked from within the git repo!"
  exit 1
fi
if [[ -z $1 ]]; then
  >&2 echo "✗ missing argument: <configuration-to-enable>"
  exit 1
fi
if [[ ! -e "$1" ]]; then
  >&2 echo "✗ $1 is not a valid path to a configuration!"
  exit 1
fi
git_root=$(2>/dev/null git rev-parse --show-toplevel)
repo_relative_configuration=${1##$git_root}
# Update the link at run/nginx.conf to point to the newly selected config
ln -sf "../${repo_relative_configuration}" run/nginx.conf
echo "✓ enabled $repo_relative_configuration"
