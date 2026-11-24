#!/usr/bin/env bash

# lenkesamler
#
# SPDX-License-Identifier: MIT
# Copyright © Josep Bigorra <jjbigorra@gmail.com>

set -euo pipefail

red_text='\033[0;31m'
reset_text='\033[0m'

log_error() {
  if [ -z "${1}" ]; then
    log_error "log_error was called without a message!"
    return 1
  fi

  echo -e "${red_text}[error] $1${reset_text}" >&2
}

log_info() {
  if [ -z "${1}" ]; then
    log_error "log_info was called without a message!"
    return 1
  fi

  # What the run says about itself goes to the error port: the standard output
  # is the document, and a document with a banner in front of it is not the
  # document -- `lenkesamler ... --mode json | jq .' is the reading this is for.
  echo -e "$1" >&2
}
