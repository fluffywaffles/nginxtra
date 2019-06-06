#!/bin/bash -e
if [[ ! $(git status) ]]; then
  >&2 echo "✗ $0 must be invoked from within the git repo!"
  exit 1
fi

git_root=$(git rev-parse --show-toplevel)
run_conf="$git_root/run/nginx.conf"
if [[ ! -e $run_conf ]]; then
  >&2 echo "✗ $run_conf does not exist!"
  >&2 echo "! try enabling a configuration."
  exit 1
fi
nginx_command=$(
  printf 'nginx -c %s -g %s'                     \
    $run_conf                                    \
    "'daemon off; pid $git_root/run/nginx.pid;'"
)

set -x # print commands when they are run
watchexec -s SIGHUP --no-vcs-ignore -f '*.conf' "$nginx_command"
