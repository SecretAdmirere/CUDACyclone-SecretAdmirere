# CUDACyclone-SecretAdmirere

GPU-accelerated search tool for [Bitcoin puzzle](https://bitcointalk.org/index.php?topic=1306983.0) addresses, written in CUDA C++.
Given a target P2PKH address (or compressed public key) and a hexadecimal private-key range, it
scans the range on an 30xx, 40xx, 50xx NVIDIA GPU and reports a matching key.

> **Scope:** This tool is intended for the public Bitcoin puzzle challenges, where the key range is
> deliberately small and known. It is not capable of recovering keys for ordinary wallets, and you
> should only use it on addresses you have the right to test.

## Donations to keep the project alive

- I recently suffered a catastrophic PSU failure that killed almost every component of my PC, and I'm now in the process of gathering funds to build a new one. Any donation would be a great help, as it will let me continue development, improve the speeds even further, and refine the search logic.
- My Bitcoin address is: `bc1q67nxvkge5ylq7fsvkhujmpvnut2a3964jqn4el`
- I currently need about $2,000 to buy used parts on my local used-listings platform.

## Requirements

- An NVIDIA RTX 30xx, 40xx or 50xx series GPU with a recent driver installed (other GPUs are not supported yet).
- Windows 10 or 11 (64-bit).

### Option 1: Download the prebuilt executable

Download the compiled Windows x64 build (supports RTX 30xx, 40xx and 50xx series):
[CUDACyclone.exe](https://github.com/SecretAdmirere/CUDACyclone-SecretAdmirere/blob/main/x64/Release/CUDACyclone.exe)

### Option 2: Build it yourself

- The latest [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads). I tested every version from 11.8 to 13.3. Performance doesn't change between versions, but register allocation does, so the latest version is the best choice.
- Visual Studio Community 2022 with: Desktop development with C++, C++ CMake tools for Windows, a Windows 10 or 11 SDK, and MSVC v143. This is everything I used to build the project.

## How does it work?

> **Search type:** this is a **randomized search**, not a sequential scan. After the first launch, every thread jumps to pseudo-random positions, and the random seed is different on every new program run. The program keeps no record of visited keys, so there is no guaranteed coverage and no guaranteed time to find a key. It is a probabilistic search.

1. **Precompute.** At startup the program builds a table of points `1×stride×G, 2×stride×G, … A×stride×G`, where A is the first `--grid` value (for example, `--grid 512,512` gives a 512-entry table). The **stride** (`--stride`) is the gap between the keys that will be checked around each starting key. It can be a decimal number (`161`) or hex with a `0x` prefix (`0xD5`), and it is always forced odd regardless of the input (stride 10 becomes 11).
2. **Split the range.** With `--divide N` the range is cut into N equal sections, and the GPU threads are shared out between them. This spreads the search over the whole range instead of one region. The thread count is SM count × B × 256, where B is the second `--grid` value, so N can't be larger than that.
3. **Place the threads.** In the first launch, each thread gets an evenly spaced starting key inside its section.
4. **Check around each start.** Every thread checks its start key and then walks outward in both directions in steps of the stride (`start ± 1×stride, 2×stride, 3×stride …`), using the table. Each key is hashed and its hash160 is compared to your target. Keys that fall between the checked ones are skipped in this launch. Example with a start of 1000, a table of 8 and stride 11:
   `912 · 923 · 934 · 945 · 956 · 967 · 978 · 989 · 1000 · 1011 · 1022 · 1033 · 1044 · 1055 · 1066 · 1077 · 1088`
   That is 2×8+1 = 17 keys per thread per launch. A bigger stride covers a wider window with the same number of keys, so the speed does not change, only which keys are checked.
5. **Random jump and repeat.** Before each new launch, every thread jumps by a random step taken from `STEPS_TABLE`, a table generated at startup from a fresh random seed. If the jump goes past the end of its section, it wraps back around inside that section. Then step 4 runs again from the new position, so a different set of keys is checked each time, until the key is found.

## Memory usage

> **Warning:** `--grid` directly controls how much GPU memory (VRAM) the program uses. A higher second value (`B`) means more threads, and more threads mean more VRAM.

- Every thread needs its own small buffers, so memory use grows with the thread count (SM count × B × 256).
- On top of that, the program needs a fixed amount of VRAM for its precomputed tables and for the working space of the threads running at any moment (each thread uses a batch of 512 points for the batched inversion).
- Always check the real usage: open **Task Manager → Performance → GPU → Dedicated GPU memory** while the program runs.
- If memory is close to full, lower `B`.
- Start with `--grid 512,512` and raise `B` gradually while watching memory.

## Usage

```bat
CUDACyclone.exe --range START:END --address <base58_address> --grid A,B --stride N [--divide N]
```
Options in `[brackets]` are optional.


| Option | Required? | Description |
|---|---|---|
| `--range START:END` | Yes | Hexadecimal search range (example: `--range 400000000000000000:7fffffffffffffffff`) |
| `--address <base58>` | Yes (or `--pubkey`) | Target Bitcoin compressed address (example: `--address 1PWo3JeB9jrGwfHDNpdGK54CRas7fsVzXU`) |
| `--pubkey <hex>` | Yes (or `--address`) | Target compressed public key. Intended for performance benchmarking only; using it to search for a public key is not recommended (example: `--pubkey 031f6a332d3c5c4f2de2378c012f429cd109ba07d69690c6c701b6bb87860d6640`) |
| `--grid A,B` | Yes | GPU grid size: A = points per batch (from 512 to 8192), B = batches per SM (example: `--grid 512,512`) |
| `--divide N` | **No** (default: `1`, no division) | Divide the range into N sections. Not needed for a normal search; it only spreads the threads over several regions of the range (example: `--divide 4`) |
| `--stride N` | Yes | Gap between the keys checked around each start (K-jumping), as a decimal number or as hex with a `0x` prefix. Always forced odd (example: stride 10 becomes 11) |
| `-h`, `--help` | No | Show help |

### Commands

```bat
==========================================================================================================================================================================================================

TEST ADDRESSES:

CUDACyclone.exe --range 400000000:7ffffffff --address 1PWCx5fovoEaoBowAvF5k91m2Xat9bMgwb --stride 0xD5 --grid 512,512

CUDACyclone.exe --range 2000000000:3fffffffff --address 1HBtApAFA9B2YZw3G2YKSMCtb3dVnjuNe2 --stride 161 --grid 512,512

CUDACyclone.exe --range 4000000000:7fffffffff --address 122AJhKLEfkFBaGAd84pLp1kfE7xK3GdT8 --stride 0xD5 --grid 512,512

CUDACyclone.exe --range 8000000000:ffffffffff --address 1EeAxcprB2PpCnr34VfZdFrkUWuxyiNEFv --stride 161 --grid 512,512

==========================================================================================================================================================================================================

TEST PUBKEYS:

CUDACyclone.exe --range 400000000:7ffffffff --pubkey 02f6a8148a62320e149cb15c544fe8a25ab483a0095d2280d03b8a00a7feada13d --stride 0xD5 --grid 4096,512

CUDACyclone.exe --range 2000000000:3fffffffff --pubkey 03c060e1e3771cbeccb38e119c2414702f3f5181a89652538851d2e3886bdd70c6 --stride 161 --grid 4096,512

CUDACyclone.exe --range 4000000000:7fffffffff --pubkey 022d77cd1467019a6bf28f7375d0949ce30e6b5815c2758b98a74c2700bc006543 --stride 0xD5 --grid 4096,512

CUDACyclone.exe --range 8000000000:ffffffffff --pubkey 03a2efa402fd5268400c77c20e574ba86409ededee7c4020e4b9f0edbee53de0d4 --stride 161 --grid 4096,512

==========================================================================================================================================================================================================

REAL TARGET ADDRESSES:

CUDACyclone.exe --range 400000000000000000:7fffffffffffffffff --address 1PWo3JeB9jrGwfHDNpdGK54CRas7fsVzXU --stride 0x466bef7e44641 --grid 512,512

CUDACyclone.exe --range 800000000000000000:ffffffffffffffffff --address 1JTK7s9YVYywfm5XUH7RNhHJH1LshCaRFR --stride 0x466bef7e44641 --grid 512,512

==========================================================================================================================================================================================================
```

_(These are only examples. Do your own due diligence and write a prompt that suits your task!)_

## Output

If a key is found it is printed to the console and appended to `FOUND_ME_A_BITCOIN.txt`.
**Keep that file private.**

## Performance

Speeds in the '**Reference**' column come from the [btcpuzzle.info GPU benchmark list](https://btcpuzzle.info/benchmark). '**This project**' column shows the speed of CUDACyclone-SecretAdmirere, which is about 27% higher. Only the RTX 3070 Ti has been tested so far. All other values are estimates calculated by applying the same 27% increase to the reference figure.

Measured speeds are the **real kernel speed** (the time the GPU spends computing keys), not an **Speed With Included Overhead** figure that includes everything in between.

| GPU | Reference (Mkeys/s) | This project (Mkeys/s) | Status |
|---|---:|---:|---|
| RTX 5090 | 8,060 | 10,236 | Estimated |
| RTX 4090 | 5,960 | 7,569 | Estimated |
| RTX 5080 | 4,520 | 5,740 | Estimated |
| RTX 4080 SUPER | 3,690 | 4,686 | Estimated |
| RTX 4080 | 3,490 | 4,432 | Estimated |
| RTX 4070 Ti SUPER | 3,240 | 4,115 | Estimated |
| RTX 3090 Ti | 2,820 | 3,581 | Estimated |
| RTX 4070 Ti | 2,680 | 3,404 | Estimated |
| RTX 3090 | 2,570 | 3,264 | Estimated |
| RTX 4070 SUPER | 2,530 | 3,213 | Estimated |
| RTX 3080 Ti | 2,480 | 3,150 | Estimated |
| RTX 3080 | 2,310 | 2,934 | Estimated |
| RTX 4070 | 2,150 | 2,731 | Estimated |
| RTX 3070 Ti | 1,760 | 2,235 | Measured (+27%) |
| RTX 3070 | 1,580 | 2,007 | Estimated |
| RTX 4060 Ti | 1,540 | 1,956 | Estimated |
| RTX 3060 Ti | 1,340 | 1,702 | Estimated |
| RTX 4060 | 1,260 | 1,600 | Estimated |
| RTX 3060 | 982 | 1,248 | Estimated |
| RTX 3050 | 708 | 900 | Estimated |

Have a different GPU? Please open an issue or a pull request with your results so the table can be updated, or comment on [Bitcoin Forum](https://bitcointalk.org/index.php?topic=5599906.msg67347221#msg67347221).

## Credits

- Inspired by [Dookoo2's CUDACyclone](https://github.com/Dookoo2/CUDACyclone)
- [Jean Luc PONS / VanitySearch](https://github.com/JeanLucPons/VanitySearch)
- [RetiredCoder / RCKangaroo](https://github.com/RetiredC/RCKangaroo)

## License

This project is licensed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE) for details.

## Disclaimer

This software is provided "as is", without warranty of any kind. You are responsible for how you use it.
