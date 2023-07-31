# challenge2_loop

## Error Description

The test was performing addition operations and self-checking for 3 sets of test cases and when run on spike it got stuck in a loop.

![error](/images/loop_error.png)

## Cause

After the successful checking of 3 sets of test cases the test should have jumped at `test_end` but it kept on performing addition operations by loading data from the subsequent memory locations (**sebsequent memory locations contained zeros**) and stuck in the self checking loop causing it to never exit from spike.

## Solution

In register `t5`, the number of sets of test cases is already stored, which is `3`. So, I have added two instructions in the test. The first at the start of the `loop:` block.

- `beqz t5, test_end`

It is taking the advantage of the fact that there is already an label defined `test_end` to end the test.

The second instruction is added before the self checking branch.

- `addi t5, t5, -1`

This instruction decrements the `t5` by `1` demonstrating that the previous set has been covered. Eventually, when all three sets of test cases are covered, `t5` will become `zero` and the test_end branch will end the test.

![solution](/images/loop_fix.png)
