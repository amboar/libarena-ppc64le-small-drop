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
P1="$(grep -v '^#' p1.reduced-broken | tr "$'\012'" " ")"
P2="$(grep -v '^#' p2.0 | tr "$'\012'" " ")"

P0A=( $P0 )
P0AL=${#P0A[@]}

for i in `seq 1 ${P0AL}`
do
	chosen="${P0A[@]:0:${P0AL}-$i}"

	./opt-once-link.sh $chosen $P1 $P2

	echo
	echo Chosen: \'$chosen\'
	echo
	! ${BIN} || exit 1
done
exit 0

