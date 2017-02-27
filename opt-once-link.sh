#!/bin/bash -x

set -eou pipefail

RUSTC=${RUSTC:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/stage2/bin/rustc}
LLC=${LLC:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/llc}
OPT=${OPT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/opt}
SRC=${SRC:-./arena.bc}
BIN=${BIN:-./arena}
CHOSEN="${@}"

$OPT ${SRC}       -o ${SRC}.opt.2 $CHOSEN

# Object file name is from the output of `rustc --test -Z print-link-args lib.rs`
$LLC -filetype=obj -o arena.0.o ${SRC}.opt.2

rm -f ${BIN}

# Rust tries to write arena.0.o despite only wanting to print the linker args!
mv arena.0.o arena.0.o.holdmybeer
echo $RUSTC --test -Z print-link-args lib.rs
linkcmd="$($RUSTC --test -Z print-link-args lib.rs)"
mv arena.0.o.holdmybeer arena.0.o
eval $linkcmd

