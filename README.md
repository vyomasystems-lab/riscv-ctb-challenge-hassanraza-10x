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