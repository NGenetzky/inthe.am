#!/bin/bash

################################################################################
# utility

echoerr() {
  echo >&2 -e "${1-}"
}

die() {
  msg=$1
  code=${2-1} # default exit status 1
  echoerr "${RED}FATAL:${NOFORMAT} $msg"
  exit "$code"
}

log_info() {
  echoerr "${GREEN}INFO:${NOFORMAT} $1"
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
  if ! _check_social_google_auth ; then
    die "check_social_google_auth()"
  else
    log_info "[0] check_social_google_auth()"
  fi
}

_check_untracked(){
  untracked="$(git ls-files --other --exclude 'ui/' --exclude '*.pyc')"
  echo "$untracked" | grep -e 'cert.pem' '-' > /dev/null || return $?
  echo "$untracked" | grep -e 'key.pem' '-' > /dev/null || return $?
  echo "$untracked" | grep -e 'crl.pem' '-' > /dev/null || return $?
}

check_untracked(){
  log_info "[ ] check_untracked()"
  if ! _check_untracked ; then
    die "check_untracked()"
  else
    log_info "[0] check_untracked()"
  fi
}

_has_docker_volume_with_name(){
  test -n "$(docker volume ls -q -f "name=$1")"
}

_check_docker_vol(){
  # volumes:
  #   db-data:
  #     external: true
  #   task-data:
  #     external: true
  #   taskd-data:
  #     external: true
  #   django-static-assets:
  #   static-assets:
  _has_docker_volume_with_name 'task-data' || return $?
  _has_docker_volume_with_name 'taskd-data' || return $?
  _has_docker_volume_with_name 'db-data' || return $?
}

check_docker_vol(){
  log_info "[ ] check_docker_vol()"
  if ! _check_docker_vol ; then
    die "check_docker_vol()"
  else
    log_info "[0] check_docker_vol()"
  fi
}

check_postgres(){
  set -x
  # From settings:
  # DATABASE_NAME = os.environ["DB_NAME"]
  # DATABASE_USER = os.environ["DB_USER"]
  # DATABASE_PASSWORD = os.environ["DB_PASS"]
  # DATABASE_HOST = os.environ["DB_SERVICE"]
  # DATABASE_PORT = os.environ["DB_PORT"]
  docker-compose exec postgres sh -c \
    'PGPASSWORD="${DB_PASS}" psql -h "${DB_SERVICE}" -p "${DB_PORT}"'
    '/var/lib/postgresql/data'

  # 'PGPASSWORD="${DB_PASS}" psql -h "${DB_SERVICE}" -p "${DB_PORT}" -U "${DB_USER}"'
  # psql -U username -d mydatabase -c 'SELECT * FROM mytable'
}


################################################################################
# main

set -eu
setup_colors

# NOTE: Use this for debugging
set -x

check_docker_vol
check_untracked
check_social_google_auth
# check_postgres
