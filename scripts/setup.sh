#!/bin/bash -e
function eprintf () {
  >&2 printf "$@"
}

# Send a HEAD request for a resource and check for a {2,3}xx status code
# NOTE: We can't follow redirects: HEAD may 403 even if GET is OK (eg S3)
function url_is_probably_ok () {
  local status=$(
    curl                         \
      --silent                   \
      --head                     \
      --connect-timeout 2        \
      --output /dev/null         \
      --write-out '%{http_code}' \
      $1
  )
  # Set a status variable in the outer scope
  declare -g url_is_probably_ok_status=$status
  # Perform brain amputation
  false                                   \
  || [[ "$status" =~ ^2[[:digit:]]{2}$ ]] \
  || [[ "$status" =~ ^3[[:digit:]]{2}$ ]] \
  || false
  # Excrete brain fluid
  return $?
}

git_root=(      $(git rev-parse --show-toplevel) )
build_root=(    $git_root/build                  )
build_bins=(    $build_root/bin                  )
watchexec_bin=( $build_bins/watchexec            )

watchexec_version=${WATCHEXEC_VERSION:-'1.10.2'}
watchexec_url_default=$(
  printf '%s%s%s%s%s'                                           \
    'https://github.com/watchexec/watchexec/releases/download/' \
    ${watchexec_version}                                        \
    '/watchexec-'                                               \
    ${watchexec_version}                                        \
    '-x86_64-unknown-linux-gnu.tar.gz'                          \
)

watchexec_url=${WATCHEXEC_TAR_GZ_URL:-$watchexec_url_default}
watchexec_tmp=$build_root/watchexec_tmp
watchexec_tar=$watchexec_tmp/watchexec.tar.gz

force_reinstall=${FORCE_REINSTALL_WATCHEXEC}
if [[ -n $FORCE_REINSTALL_WATCHEXEC ]]; then
  eprintf '! HEY ! FORCE_REINSTALL_WATCHEXEC is for debugging.\n'
fi

if [[ -e $watchexec_bin ]] && [[ ! -x $watchexec_bin ]]; then
  eprintf '! `watchexec` found, but it is not executable.\n'
  eprintf '! forcing a reinstall...\n'
  force_reinstall=1
fi

if [[ -n $force_reinstall ]] && [[ -e $watchexec_bin ]]; then
  rm $watchexec_bin
fi

if [[ ! -x $watchexec_bin ]]; then
  eprintf '! `watchexec` not found!\n'
  sys_watchexec_bin=$(which watchexec; :)
  if [[ -z $NO_SYSTEM_WATCHEXEC ]] && [[ -x $sys_watchexec_bin ]]; then
    eprintf '∙ linking system `watchexec` (%s)...\n' $sys_watchexec_bin
    ln -s $sys_watchexec_bin $watchexec_bin
    eprintf '∙ linked.\n'
    eprintf '! changes were made !\n'
    eprintf '! please read the logs above and re-run this command.\n'
    exit 1
  elif [[ -z $NO_DOWNLOAD_WATCHEXEC ]]; then
    eprintf '∙ checking for prebuilt `watchexec` at:\n    %s\n' \
      $watchexec_url
    if url_is_probably_ok $watchexec_url; then
      eprintf '∙ downloading prebuilt `watchexec` to:\n    %s\n\n' \
        "${watchexec_tar##$(pwd)/}"
      mkdir -p $watchexec_tmp
      curl                      \
        --location              \
        $watchexec_url          \
        --output $watchexec_tar
      eprintf '\n∙ downloaded tarball to:\n    %s\n' \
        $watchexec_tar
      eprintf '∙ extracting tarball...\n'
      tar --extract                \
        --directory $watchexec_tmp \
        -f $watchexec_tar
      extracted=$( find $watchexec_tmp -executable -name watchexec )
      if [[ -z $extracted ]]; then
        eprintf '✗ could not find extracted `watchexec` executable?!\n'
        eprintf '! leaving behind temporary files for debugging.\n'
        eprintf '! this is an error and should not happen - sorry!\n'
        eprintf '! look for the `watchexec` executable in:\n    %s\n' \
          "${watchexec_tmp##$(pwd)/}"
        eprintf '%s\n%s\n%s\n'                                       \
          '! you can recover by manually installing `watchexec` at:' \
          "    ${watchexec_bin##$(pwd)/}"                            \
          '  and then re-running this script.'
        exit 2
      fi
      eprintf '∙ found `watchexec` extracted at:\n    %s\n' \
        "${extracted##$(pwd)/}"
      eprintf '∙ moving extracted `watchexec` to:\n    %s\n' \
        "${watchexec_bin##$(pwd)/}"
      mv $extracted $watchexec_bin
      eprintf '∙ clean-up: removing temporary directory:\n    %s\n' \
        "${watchexec_tmp##$(pwd)/}"
      rm -rf $watchexec_tmp
      eprintf '! changes were made !\n'
      eprintf '! please read the logs above and re-run this command.\n'
      exit 1
    else
      eprintf '✗ not ok (%s)\n' $url_is_probably_ok_status
      exit 2
    fi
  else
    eprintf '✗ no automatic resolution available; sorry!\n'
    exit 2
  fi
fi

printf '✓ all good, mon frere!\n'
