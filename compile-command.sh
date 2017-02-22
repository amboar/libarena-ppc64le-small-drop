#!/bin/bash -x

set -eou pipefail

RUSTC=${RUSTC:-/home/arj/.cargo/bin/rustc}
BUGPOINT=${BUGPOINT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/bugpoint}
LLC=${LLC:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/llc}
OPT=${OPT:-/home/arj/rust-release/build/powerpc64le-unknown-linux-gnu/llvm/bin/opt}
SRC=${SRC:-./arena.bc}

$RUSTC --crate-name arena lib.rs --emit=dep-info,link --test -C metadata=75d30fcb0454b8ed --out-dir . -L dependency=/home/arj/small-drop/target/release/deps --emit llvm-bc

# P0="-tti -tbaa -scoped-noalias -assumption-cache-tracker -targetlibinfo -verify -simplifycfg -domtree -sroa -early-cse -lower-expect"
# P1="-targetlibinfo -tti -tbaa -scoped-noalias -assumption-cache-tracker -profile-summary-info -forceattrs -inferattrs -ipsccp -globalopt -domtree -mem2reg -deadargelim -domtree -basicaa -aa -instcombine -simplifycfg -pgo-icall-prom -basiccg -globals-aa -prune-eh -always-inline -functionattrs -domtree -sroa -early-cse -speculative-execution -lazy-value-info -jump-threading -correlated-propagation -simplifycfg -domtree -basicaa -aa -instcombine -tailcallelim -simplifycfg -reassociate -domtree -loops -loop-simplify -lcssa -basicaa -aa -scalar-evolution -loop-rotate -licm -loop-unswitch -simplifycfg -domtree -basicaa -aa -instcombine -loops -loop-simplify -lcssa -scalar-evolution -indvars -loop-idiom -loop-deletion -loop-unroll -memdep -memcpyopt -sccp -domtree -demanded-bits -bdce -basicaa -aa -instcombine -lazy-value-info -jump-threading -correlated-propagation -domtree -basicaa -aa -memdep -dse -loops -loop-simplify -lcssa -aa -scalar-evolution -licm -adce -simplifycfg -domtree -basicaa -aa -instcombine -barrier -basiccg -rpo-functionattrs -globals-aa -float2int -domtree -loops -loop-simplify -lcssa -basicaa -aa -scalar-evolution -loop-rotate -loop-accesses -branch-prob -lazy-block-freq -opt-remark-emitter -loop-distribute -loop-simplify -lcssa -branch-prob -block-freq -scalar-evolution -basicaa -aa -loop-accesses -demanded-bits -loop-vectorize -loop-simplify -scalar-evolution -aa -loop-accesses -loop-load-elim -basicaa -aa -instcombine -simplifycfg -domtree -basicaa -aa -instcombine -loops -loop-simplify -lcssa -scalar-evolution -loop-unroll -instcombine -loop-simplify -lcssa -scalar-evolution -licm -instsimplify -scalar-evolution -alignment-from-assumptions -strip-dead-prototypes -verify"
# P2="-domtree"

P0="-tti -tbaa -scoped-noalias -assumption-cache-tracker -targetlibinfo -verify -simplifycfg -domtree -sroa -early-cse -lower-expect"
P1="-targetlibinfo -tti -tbaa -scoped-noalias -assumption-cache-tracker -profile-summary-info -forceattrs -inferattrs -ipsccp -globalopt -domtree -mem2reg -deadargelim -domtree -basicaa -aa -instcombine -simplifycfg -pgo-icall-prom -basiccg -globals-aa -prune-eh -inline -functionattrs -domtree -sroa -early-cse -speculative-execution -lazy-value-info -jump-threading -correlated-propagation -simplifycfg -domtree -basicaa -aa -instcombine -tailcallelim -simplifycfg -reassociate -domtree -loops -loop-simplify -lcssa -basicaa -aa -scalar-evolution -loop-rotate -licm -loop-unswitch -simplifycfg -domtree -basicaa -aa -instcombine -loops -loop-simplify -lcssa -scalar-evolution -indvars -loop-idiom -loop-deletion -loop-unroll -mldst-motion -aa -memdep -gvn -basicaa -aa -memdep -memcpyopt -sccp -domtree -demanded-bits -bdce -basicaa -aa -instcombine -memdep -gvn -lazy-value-info -jump-threading -correlated-propagation -domtree -basicaa -aa -memdep -dse -loops -loop-simplify -lcssa -aa -scalar-evolution -licm -adce -simplifycfg -domtree -basicaa -aa -instcombine -barrier -elim-avail-extern -basiccg -rpo-functionattrs -globals-aa -float2int -domtree -loops -loop-simplify -lcssa -basicaa -aa -scalar-evolution -loop-rotate -loop-accesses -branch-prob -lazy-block-freq -opt-remark-emitter -loop-distribute -loop-simplify -lcssa -branch-prob -block-freq -scalar-evolution -basicaa -aa -loop-accesses -demanded-bits -loop-vectorize -loop-simplify -scalar-evolution -aa -loop-accesses -loop-load-elim -basicaa -aa -instcombine -scalar-evolution -demanded-bits -slp-vectorizer -simplifycfg -domtree -basicaa -aa -instcombine -loops -loop-simplify -lcssa -scalar-evolution -loop-unroll -instcombine -loop-simplify -lcssa -scalar-evolution -licm -instsimplify -scalar-evolution -alignment-from-assumptions -strip-dead-prototypes -globaldce -constmerge -verify"
P2="-domtree"

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
