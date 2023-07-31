# challenge1_logical

## Error Description

On running the `make` command, the assembler printed the following error messages.

1. test.S:15855: Error: illegal operands `and s7,ra,z4`
2. test.S:25584: Error: illegal operands `andi s5,t1,s0`

The above messages indicated that there were illegal operands on the mentioned lines in *test.S*

![error](/images/error_logical_.png)

## Cause

1. The problem with the first instruction was that it was using `z4` as a source register but there is no register with name `z4` in RISC-V.

2. The second instruction was using `andi` an immediate instruction with no immediate value as source. The destination and source registers format specified in the instruction is for a R-type instruction.

## Solution

1. For instruction 1, `z4` has been replaced with `t1` - temporary register.

2. For instruction 2, As all the instructions in the test are using R-type instructions so this instruction has also been made a R-type by simply removing the `i` suffix.

The corrected instructions are

1. `and s7, ra, t1`
2. `and s5, t1, s0`

The image of the fix.

![solution](/images/logical_sol.png)
