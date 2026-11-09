# Stockfish in Chess Offline

This is the complete source code of the **Stockfish** chess engine as it is shipped inside the Android app
**Chess Offline** by Hornbill Games (package `com.hornbillgames.chessoffline`).

Stockfish is free software under the **GNU General Public License v3** (see `Copying.txt`), written by the Stockfish
developers (see `AUTHORS`). It is not made by Hornbill Games. The app runs it as a separate program and talks to it
with UCI text commands, for game analysis, hints, game reviews and the strongest computer level.

## Exactly what is in the app

| Part | Value |
|---|---|
| Stockfish | release **Stockfish 19**, tag `sf_19`, commit `edb0d9db6731067ec50ce619ff372b463bc4dd5d` (https://github.com/official-stockfish/Stockfish) |
| One change | commit `81348d3fb4f68bda5c442e7459de78ab00acbc55` from https://github.com/niklasf/Stockfish, "simple mirrored piece square features" (sscg13, rebased by Niklas Fiekas): it makes Stockfish use the small "light" network, as the Lichess mobile app does. It is in `patches/`; this folder is `sf_19` with that commit applied (commit `fbe982f75c625318615f9eb49bd937a75cab13ed`). |
| Network | `net/nn-61e7af4bb97d.nnue`, 1,166,381 bytes, SHA-256 `61e7af4bb97d51eeeb25d322916f86513b5cd3a827ce189c98c6e31946f99e5b`, embedded into the program at build time |
| Other changes | none (only `.gitignore` lets the network file into this repository) |
| Compiler | Android NDK r27c (27.2.12479018) |
| Android build | `ARCH=arm64-universal COMP=ndk`, statically linked, stripped, 16 KB page alignment: run `build-chess-offline.sh` |
| Check | `stockfish bench` prints `Nodes searched : 2793281` (`./build-chess-offline.sh mac` builds and checks it) |

The program in the app is `lib/arm64-v8a/libstockfish.so` (an executable, named like a library so Android installs it
next to the app). Phones with a 32-bit Android do not get Stockfish; the app uses its other engine there.

## Building

```bash
NDK=/path/to/android-ndk-r27c ./build-chess-offline.sh
```

The result is `out/libstockfish.so`.

## Licence

GNU General Public License v3, see `Copying.txt`. You may use, study, change and share this code under that licence.
