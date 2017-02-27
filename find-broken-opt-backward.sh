#!/bin/bash -x

set -eou pipefail

RUSTC=${RUSTC:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/stage2/bin/rustc}
BUGPOINT=${BUGPOINT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/bugpoint}
LLC=${LLC:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/llc}
OPT=${OPT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/opt}
SRC=${SRC:-./arena.bc}
BIN=${BIN:-./arena}
ITER=${1-0}

$RUSTC --crate-name arena lib.rs --emit=dep-info,link --test -C metadata=75d30fcb0454b8ed --out-dir . -L dependency=./target/release/deps --emit llvm-bc

P0="$(grep -v '^#' p0.0 | tr "$'\012'" " ")"
P1="$(grep -v '^#' p1.pre-upper-broken | tr "$'\012'" " ")"
P2="$(grep -v '^#' p2.0 | tr "$'\012'" " ")"

P1A=( $P1 )
P1AL=${#P1A[@]}

for i in `seq 0 ${P1AL}`
do
	chosen="${P1A[@]:0:${P1AL}-$i}"

	./opt-link.sh $chosen -instcombine

	echo
	echo Chosen: \'$chosen\'
	echo
	! ${BIN} || exit 1
done
exit 0

