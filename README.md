# Verilog Matrix Multiplication

> Hardware implementation of matrix multiplication in Verilog, including vector addition, scalar multiplication, and configurable matrix dimensions with waveform verification.

## Overview

This project implements matrix multiplication at the hardware level using Verilog HDL. It includes modular components for addition, multiplication, and accumulation, designed to be synthesizable on FPGAs. Test cases with expected outputs and waveform screenshots are provided for verification.

## Components

- **Adder modules** — parameterized adders for vector/matrix element operations
- **Multiplier modules** — scalar and vector multiplication units
- **Matrix multiplication** — full NxN matrix multiply with configurable dimensions
- **Testbenches** — test cases with sample inputs and golden outputs

## Verification

Test cases (`Sample1.txt` through `Sample4.txt`) with corresponding waveform screenshots and golden output comparisons in the `Screenshots/` directory.

## Tech Stack

- Verilog HDL
- ModelSim / Icarus Verilog for simulation
- GTKWave for waveform viewing

*Digital Logic Design Course, Summer 2021*
