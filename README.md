# CUDACyclone

GPU-accelerated search tool for Bitcoin puzzle ("Bitcoin Challenge") addresses, written in CUDA C++.
Given a target P2PKH address (or compressed public key) and a hexadecimal private-key range, it
scans the range on an NVIDIA GPU and reports a matching key.

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

- NVIDIA GPU with a recent driver
- [CUDA Toolkit](https://developer.nvidia.com/cuda-downloads) (version: _fill in, e.g. 12.x_)
- Windows + Visual Studio (MSVC) — the code currently includes `<windows.h>`

## Build

```bat
:: Run from a "x64 Native Tools Command Prompt for VS"
nvcc -O3 -arch=sm_XX CUDACyclone.cu -o CUDACyclone.exe
```

Replace `sm_XX` with your GPU's compute capability (for example `sm_86` for RTX 30-series,
`sm_89` for RTX 40-series).

## Usage

```bat
CUDACyclone.exe --range START:END --address <base58_address> [options]
```

| Option | Description |
|---|---|
| `--range START:END` | Hexadecimal search range |
| `--address <base58>` | Target Bitcoin address (compressed only) |
| `--pubkey <hex>` | Target public key (compressed only, and used as a performance benchmark ONLY, don't recomend using it to search for public keys) |
| `--grid A,B` | GPU grid size (points per batch, batches per SM) |
| `--divide N` | Divide the range into N sections (default: 1) |
| `--stride N` | Stride value for K-jumping (default: 3) |
| `-h`, `--help` | Show help |

### Example

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

_(Those are exsamples only, you have to do your own due diligence and make a prompt suitable for the task you want to complite!)_

## Output

If a key is found it is printed to the console and appended to `FOUND_ME_A_BITCOIN.txt`.
**Keep that file private.**

## Performance

_Add your benchmarks here (GPU model, keys/second)._

## Credits

_List any projects, papers or people whose code or ideas you used (this matters for GPL compliance)._

## License

This project is licensed under the **GNU General Public License v3.0**. See [LICENSE](LICENSE) for details.

## Disclaimer

This software is provided "as is", without warranty of any kind. You are responsible for how you use it.
