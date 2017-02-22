#!/bin/bash

set -eou pipefail

LLC=${LLC=-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/llc}
BUGPOINT=${BUGPOINT=-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/bugpoint}

$BUGPOINT -compile-custom -compile-command ./compile-command.sh
