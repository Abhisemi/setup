#!/usr/bin/env bash
# sweep.sh — run both binaries across N; paste into a spreadsheet or gnuplot.
set -euo pipefail
for p in 10 12 14 16 18 20 22 24 26; do
  n=$((1 << p))
  ./vadd_cpu "$n" 10
  ./vadd_gpu "$n" 10
done
