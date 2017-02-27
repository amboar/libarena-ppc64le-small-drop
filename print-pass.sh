#!/bin/bash

set -eou pipefail

grep -v '^#' "$1" | tr "$'\012'" " "
echo
