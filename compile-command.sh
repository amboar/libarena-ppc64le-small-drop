#!/bin/bash -x

set -eou pipefail

RUSTC=${RUSTC:-/home/arj/.cargo/bin/rustc}
BUGPOINT=${BUGPOINT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/bugpoint}
LLC=${LLC:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/llc}
OPT=${OPT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/opt}
SRC=${SRC:-./arena.bc}
ITER=${1-0}

$RUSTC --crate-name arena lib.rs --emit=dep-info,link --test -C metadata=75d30fcb0454b8ed --out-dir . -L dependency=/home/arj/small-drop/target/release/deps --emit llvm-bc

P0="$(grep -v '^#' p0.0 | tr "$'\012'" " ")"
P1="$(grep -v '^#' p1.${ITER} | tr "$'\012'" " ")"
P2="$(grep -v '^#' p2.0 | tr "$'\012'" " ")"

$OPT ${SRC}       -o ${SRC}.opt.0 $P0
$OPT ${SRC}.opt.0 -o ${SRC}.opt.1 $P1
$OPT ${SRC}.opt.1 -o ${SRC}.opt.2 $P2

$LLC -filetype=obj -o "$SRC".o "$SRC".opt.2

# Output of `rustc --test -Z print-link-args lib.rs`
"cc" \
	"-Wl,--as-needed" \
	"-Wl,-z,noexecstack" \
	"-m64" \
	"-L" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib" \
	"${SRC}.o" \
	"-o" "${SRC}.bin" \
	"-Wl,--gc-sections" \
	"-pie" \
	"-nodefaultlibs" \
	"-L" "/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib" \
	"-Wl,-Bstatic" \
	"-Wl,-Bdynamic" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libtest-b48219465f029877.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libgetopts-73f5a5c68bc00f38.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libterm-78c30e2133d07853.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libstd-9a66b6a343d52844.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libpanic_unwind-9d79f761aa668a33.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libunwind-2beb731af7a6faec.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/librand-6bc49e032a89c77d.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libcollections-a2a467c3ca3b6479.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/liballoc-ce7b9706e1719f27.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/liballoc_system-5636d8d1255715e9.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/liblibc-95af4192ed69a1c8.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libstd_unicode-e54225ff8f33e08f.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libcore-cd0ca85e71f914ca.rlib" \
	"/home/arj/.rustup/toolchains/nightly-powerpc64le-unknown-linux-gnu/lib/rustlib/powerpc64le-unknown-linux-gnu/lib/libcompiler_builtins-0bf24067248742a8.rlib" \
	"-l" "dl" \
	"-l" "rt" \
	"-l" "pthread" \
	"-l" "gcc_s" \
	"-l" "c" \
	"-l" "m" \
	"-l" "rt" \
	"-l" "util"

./arena.bc.bin
