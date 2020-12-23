#!/bin/bash

################################################################################
# utility

echoerr() {
  echo >&2 -e "${1-}"
}

die() {
  msg=$1
  code=${2-1} # default exit status 1
  echoerr "${RED}[FATAL]${NOFORMAT} $msg"
  exit "$code"
}

log_info() {
  echoerr "${GREEN}[INFO]${NOFORMAT} $1"
}

setup_colors() {
  # shellcheck disable=SC2034
  if [ -t 2 ] && [ -z "${NO_COLOR-}" ] && [ "${TERM-}" != "dumb" ]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

################################################################################
# private functions

_check_social_google_auth(){
  grep -n \
    -e '^SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET=.*$' \
    .private.env
  grep -n \
    -e '^SOCIAL_AUTH_GOOGLE_OAUTH2_KEY=.*$' \
    .private.env
}

check_social_google_auth(){
  log_info "[ ] check_social_google_auth()"
  if ! check_social_google_auth ; then
    die "check_social_google_auth()"
  else
    log_info "[0] check_social_google_auth()"
  fi
}

################################################################################
# main

set -eu
setup_colors

check_social_google_auth
