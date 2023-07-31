# challenge1_instructions

## Problem Description

When the `make` command is run, a number of assembler error messages show up. Some of them are the following:

- test.S:156: Error: unrecognized opcode `divuw t3,s0,t2'`
- test.S:163: Error: unrecognized opcode `remw s0,s0,s0'`

![error](/images/instruction_error.png)

## Cause

These messages indicate that there are instructions in `test.S` which are not known to risc-v compiler. As, the compiler is configured with `-march=rv32i`, so it only recognizes `rv32i` instructions and doesn't recognize the instructions from the other extensions.

The above mentioned instructions are from `rv64m` that's why, those are unrecognized by the compiler.

## Solution

In `rv32.yaml` file, the `isa-instruction-distribution` section has  `rel_rv64m: 10` which means, the `rv64m` instructions will be generated around (10/40 * 1000 = 250) times (approximately) in `test.S`.

- `rel_rv64m: 10` has been replaced with `rel_rv64m: 0`. So, now no instruction from this extension will be generated and the the test will be successfully compiled and run on spike.

The snapshot of the change in `rv32i.yaml` file:

![solution](/images/instruction_sol.png)