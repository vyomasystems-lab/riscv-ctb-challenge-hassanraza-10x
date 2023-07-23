# riscv_ctb_challenges

## challenge_level1

### challenge1_logical

#### Error Description

On running the `make` command, the assembler printed the following error messages

1. test.S:15855: Error: illegal operands `and s7,ra,z4`
2. test.S:25584: Error: illegal operands `andi s5,t1,s0`

The above messages indicated that there were illegal operands on the mentioned lines in *test.S*

#### Cause

1. The problem with the first instruction was that it was using `z4` as a source register but there is no register with name `z4` in RISC-V.

2. The second instruction was using `andi` an immediate instruction with no immediate value as source. The destination and source registers format specified in the instruction is for a R-type instruction.

#### Solution

1. For instruction 1, `z4` has been replaced with `t1` - temporary register.

2. For instruction 2, As all the instructions in the test are using R-type instructions so this instruction has also been made a R-type by simply removing the `i` suffix.

The corrected instructions are

1. `and s7, ra, t1`
2. `and s5, t1, s0`

### challenge2_loop

#### Error Description

The test was performing addition operations and self-checking for 3 sets of test cases and when run on spike it got stuck in a loop.

#### Cause

After the successful checking of 3 sets of test cases the test should have jumped at `test_end` but it kept on performing addition operations by loading data from the subsequent memory locations (**sebsequent memory locations contained zeros**) and stuck in the self checking loop causing it to never exit from spike.

#### Solution

In register `t5`, the number of sets of test cases is already stored which is `3`. So, I have added two instructions in the test. The first at the start of the `loop:` block.

- `beqz t5, test_end`

It is taking the advantage of the fact that there is already an label defined `test_end` to end the test.

The second instruction is added before the self checking branch.

- `addi t5, t5, -1`

This instruction decrements the `t5` by `1` demonstrating that the previous set has been covered. Eventually, when all three sets of test cases are covered, `t5` will become `zero` and the test_end branch will end the test.

### challenge3_illegal

#### Error Description

When the test executes an illegal instruction. It gets stuck in a loop and never exits spike.

#### Cause

On executing the illegal instruction, the test jumps to `trap_vector` and here it checks whether the exception was due to an environment call or not. As, in our case the cause was not an evnironment call, so the test jumps to `mtvec_handler`.

In `mtvec_handler`, the test makes sure that the cause was an `illegal instruction` with the help of a self check and then jumps to the address stored in `mepc`, which is the address of the same illegal instruction. Thus, our test again and again runs the same illegal instruciton followed by trap handler code and remains in this loop.

#### Solution

In `mtvec_handler`, after making it sure that the cause of the exception was an `illegal instruction`. The test should update the value of the `mepc` by `8` (as there are no compressed insturctions so we don't need to check the two least significant bits to know about the length of the instruction) and then execute `mret`.

After this instruction which reads the value of `mepc` register in `mtvec_handler`.
- `csrr t0, mepc`

I have added these two instructions to increment the address in mepc by `8`.
- `addi t0, t0, 8`
- `csrw mepc, t0`
