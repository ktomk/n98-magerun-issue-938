#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

../build-mageruns/n98-magerun/bin/n98-magerun "$@"
