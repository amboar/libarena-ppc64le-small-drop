#!/bin/bash -x

set -eou pipefail

RUSTC=${RUSTC:-/home/arj/.cargo/bin/rustc}
BUGPOINT=${BUGPOINT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/bugpoint}
SRC=${SRC:-./arena.bc}

$RUSTC --crate-name arena lib.rs --emit=dep-info,link --test -C metadata=75d30fcb0454b8ed --out-dir . -L dependency=/home/arj/small-drop/target/release/deps --emit llvm-bc

$BUGPOINT -compile-custom -compile-command ./compile-command.sh $SRC
