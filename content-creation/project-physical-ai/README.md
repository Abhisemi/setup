# Project Physical AI — course code

Companion code for the **Project Physical AI** video series (Intro to GPUs → CUDA →
inference performance → Physical AI / robotics stack).

The plan, scripts, production playbook, resource library and trackers live in Notion
under **Content Creation → Project Physical AI**. This folder only holds the code that
appears on screen, one sub-folder per episode.

| Episode | Folder | What it shows |
|---|---|---|
| Ep 3 — Your first CUDA kernel | `ep03-first-kernel/` | CPU vector add vs CUDA kernel, timed with CUDA events; PCIe copy cost and the crossover |

## Conventions

- Each episode folder has a `README_recording.md` with the exact commands and expected
  output, so retakes are consistent.
- Tag checkpoints as `step-01`, `step-02`, … so code can be revealed stage by stage on
  camera instead of typed live.
- Timing numbers in the scripts are ballpark until replaced with measured output from
  the recording machine. Name the machine on screen.
