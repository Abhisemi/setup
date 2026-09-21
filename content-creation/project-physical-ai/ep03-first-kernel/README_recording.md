# Ep 3 — Your first CUDA kernel: recording notes

Machine for the on-screen numbers: **(fill in: GPU, CPU, PCIe gen, pageable host memory)**.

## Build

```bash
gcc -O2 -Wall -o vadd_cpu vadd_cpu.c
nvcc -O2 -o vadd_gpu vadd_gpu.cu
chmod +x sweep.sh
```

## Reveal order

1. `vadd_cpu.c` complete, then run at 1024 and 1048576.
2. `vadd_gpu.cu` stage 1: includes, `CUDA_CHECK`, kernel (`// [S1]` lines).
3. Stage 2: host code — allocate, copy, launch, copy back, verify (`// [S2]`).
4. Stage 3: warm-up and CUDA events (`// [S3]`).
5. Stage 4: `iters` loop (`// [S4]`).
6. `sweep.sh`, then the log-log plot.
7. `cudaMallocManaged` aside (snippet in the script).

## Commands and expected output shape

```bash
./vadd_cpu 1024
./vadd_gpu 1024        # GPU total ~40x slower than CPU; kernel ~6 us, mostly launch overhead
./vadd_cpu 1048576
./vadd_gpu 1048576     # kernel ~25x faster than CPU; total still ~2x slower because of copies
./vadd_cpu 1048576 100
./vadd_gpu 1048576 100 # ~15x faster end to end once copies are amortised
./sweep.sh
```

Replace every number in the script with the measured output before recording.
