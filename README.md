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
| `--pubkey <hex>` | Target compressed public key (alternative to `--address`) |
| `--grid A,B` | GPU grid size (points per batch, batches per SM) |
| `--divide N` | Divide the range into N sections (default: 1) |
| `--stride N` | Stride value for K-jumping (default: 3) |
| `-h`, `--help` | Show help |

### Example

```bat
CUDACyclone.exe --range 200000000:3FFFFFFFF --address 1EXAMPLEADDRESSHERE --grid 512,256
```

_(Replace with a real puzzle address and range of your choice.)_

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
