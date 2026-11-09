#!/bin/bash
# Builds, from this folder, the exact Stockfish program that the Android app "Chess Offline" (Hornbill Games) ships.
#
#   ./build-chess-offline.sh              Android arm64 program  -> out/libstockfish.so
#   ./build-chess-offline.sh mac          macOS (Apple silicon) build, then checks the bench number
#
# Needs: make, and for Android the Android NDK r27c (27.2.12479018). Set NDK to its folder, for example
#   NDK=~/Library/Android/sdk/ndk/27.2.12479018 ./build-chess-offline.sh
# On Linux, change "darwin-x86_64" below to "linux-x86_64".
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
NET=nn-61e7af4bb97d.nnue
NET_SHA256=61e7af4bb97d51eeeb25d322916f86513b5cd3a827ce189c98c6e31946f99e5b
BENCH=2793281
JOBS=$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)

cp "$HERE/net/$NET" "$HERE/src/$NET"
(cd "$HERE/src" && echo "$NET_SHA256  $NET" | shasum -a 256 -c -)
mkdir -p "$HERE/out"

if [ "${1:-android}" = "mac" ]; then
  (cd "$HERE/src" && make -j"$JOBS" build ARCH=apple-silicon COMP=clang)
  got=$("$HERE/src/stockfish" bench 2>&1 | awk '/Nodes searched/ {print $4}')
  echo "bench: $got (expected $BENCH)"
  [ "$got" = "$BENCH" ] || { echo "BENCH MISMATCH"; exit 1; }
  cp "$HERE/src/stockfish" "$HERE/out/stockfish-macos"
  exit 0
fi

: "${NDK:?set NDK to the Android NDK r27c folder}"
export PATH="$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"
export LDFLAGS="-static -Wno-unused-command-line-argument"      # as Stockfish's own arm_compilation.yml CI job
cd "$HERE/src"
# SHELL=/bin/bash: on macOS /bin/sh's echo prints "-n", which breaks the network hex dump of the universal build.
# The two linker flags align the program to 16 KB pages (Google Play's rule for Android 15+; NDK r28+ does it by default).
make -j"$JOBS" build SHELL=/bin/bash ARCH=arm64-universal COMP=ndk \
  EXTRALDFLAGS="-Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384"
llvm-strip stockfish
cp stockfish "$HERE/out/libstockfish.so"
file "$HERE/out/libstockfish.so" || true
shasum -a 256 "$HERE/out/libstockfish.so"
