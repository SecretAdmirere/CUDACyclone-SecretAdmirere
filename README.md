# CUDACyclone-SecretAdmirere

GPU-accelerated search tool for [Bitcoin puzzle](https://bitcointalk.org/index.php?topic=1306983.0) addresses, written in CUDA C++.
Given a target compressed P2PKH address (or compressed public key) and a hexadecimal private-key range, it
scans the range on an NVIDIA RTX 30-, 40- or 50-series GPU and reports a matching key.

> **Scope:** This tool is intended for the public Bitcoin puzzle challenges, where the key range is
> deliberately small and known. It is not capable of recovering keys for ordinary wallets, and you
> should only use it on addresses you have the right to test.

## Features

- Runs on NVIDIA GPUs via CUDA
- Target by Base58 address (compressed P2PKH) or compressed public key
- Custom search range, range splitting (`--divide`), and stride/K-jumping (`--stride`)
- Tunable GPU grid (`--grid`)
- Writes the result to `FOUND_ME_A_BITCOIN.txt` when a key is found

## Requirements

- Requires an NVIDIA RTX 30-, 40- or 50-series GPU with a recent driver installed.
- Latest [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads), i have tested every version from 11.8 up until 13.3 and have concluded that using the latest version is the best, the performance doesn't change from version to version but register allocation does. So just use the latest [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads).
- Windows 10 or 11, Visual Studio Community 2022, C++ core desktop features, C++ CMake tools for Windows, Windows 10 or 11 SDK, MSVC v143 (I listed everything i used for building the project).

## How does it work?

- **Precompute.** At startup the program builds a table of points `1×stride×G, 2×stride×G, … A×stride×G`, where A is the first `--grid` value (for example, `--grid 512,512` gives a 512-entry table). The stride is always forced odd regardless of the input (stride 10 becomes 11).
- **Split the range.** With `--divide N` the range is cut into N equal sections, and the GPU threads are shared out between them. This spreads the search over the whole range instead of one region. The thread count is SM count × B × 256, where B is the second `--grid` value, so N can't be larger than that.
- **Place the threads.** In the first launch, each thread gets an evenly spaced starting key inside its section.
- **Check around each start.** Every thread checks its start key and then walks outward in both directions using the table, hashing each key and comparing its hash160 to your target. Example with a start of 1000, a table of 8 and stride 11:
   `912 · 923 · 934 · 945 · 956 · 967 · 978 · 989 · 1000 · 1011 · 1022 · 1033 · 1044 · 1055 · 1066 · 1077 · 1088`
   That is 2×8+1 = 17 keys per thread per launch.
- **Jump and repeat.** Before each new launch, every thread jumps by a random step taken from `STEPS_TABLE`. If the jump goes past the end of its section, it wraps back around inside that section. Then step 4 runs again until the key is found.

Replace `sm_XX` with your GPU's compute capability (for example `sm_86` for RTX 30-series,
`sm_89` for RTX 40-series).

## Usage

```bat
CUDACyclone.exe --range START:END --address <base58_address> [options]
```

| Option | Description |
|---|---|
| `--range START:END` | Hexadecimal search range (example: --range 400000000:7ffffffff) |
| `--address <base58>` | Target Bitcoin compressed address (example: --address 1PWo3JeB9jrGwfHDNpdGK54CRas7fsVzXU) |
| `--pubkey <hex>` | Target compressed public key. Intended for performance benchmarking only; using it to search for a public key is not recommended (example: --pubkey 03a2efa402fd5268400c77c20e574ba86409ededee7c4020e4b9f0edbee53de0d4) |
| `--grid A,B` | GPU grid size: A = points per batch, B = batches per SM (example: --grid 512,512) |
| `--divide N` | Divide the range into N sections (example: --divide 4) |
| `--stride N` | Stride value for K-jumping, given as a decimal number or as hex. Hex values must start with 0x (example: --stride 161 or --stride 0xD5) |
| `-h`, `--help` | Show help |

### Test commands

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

_It is faster by 27% on NVIDIA RTX 30-, 40- or 50-series GPU then anything else that is publicly avaliable online_

  ## Credits

  - Inspired by [Dookoo2's CUDACyclone](https://github.com/Dookoo2/CUDACyclone)
  - [Jean Luc PONS / VanitySearch](https://github.com/JeanLucPons/VanitySearch)
  - [RetiredCoder / RCKangaroo](https://github.com/RetiredC/RCKangaroo)

## License

This project is licensed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE) for details.

## Disclaimer

This software is provided "as is", without warranty of any kind. You are responsible for how you use it.
