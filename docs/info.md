# AES-128 2-round unrolled accelerator

This Tiny Tapeout project implements an AES-128 encryption accelerator. The AES core is a partially unrolled 2-round design, meaning two AES rounds are evaluated in one clock cycle inside the core. Because Tiny Tapeout has limited external I/O pins, the 128-bit key, 128-bit plaintext, and 128-bit ciphertext are accessed using an 8-bit byte-serial wrapper.

## Pin interface

- `ui_in[7:0]`: input byte for loading key or plaintext.
- `uio_in[0]`: pulse for one clock cycle to load one key byte.
- `uio_in[1]`: pulse for one clock cycle to load one plaintext byte.
- `uio_in[2]`: pulse for one clock cycle to start AES encryption.
- `uio_in[3]`: pulse for one clock cycle to advance to the next ciphertext byte.
- `uo_out[7:0]`: current ciphertext byte.
- `uio_out[4]`: AES busy status.
- `uio_out[5]`: AES done status.
- `uio_out[6]`: key_ready, high after 16 key bytes have been loaded.
- `uio_out[7]`: plaintext_ready, high after 16 plaintext bytes have been loaded.

## How to use

1. Reset the design by pulling `rst_n` low, then return it high.
2. Load 16 key bytes through `ui_in[7:0]`, MSB first. Pulse `uio_in[0]` once for each byte.
3. Load 16 plaintext bytes through `ui_in[7:0]`, MSB first. Pulse `uio_in[1]` once for each byte.
4. Pulse `uio_in[2]` once to start encryption.
5. Wait for `uio_out[5]` to become high.
6. Read the first ciphertext byte from `uo_out[7:0]`.
7. Pulse `uio_in[3]` to advance through the remaining ciphertext bytes.

## Verification

The included ModelSim testbench loads AES known-answer test vectors through the Tiny Tapeout serial wrapper and checks the ciphertext output byte by byte.

