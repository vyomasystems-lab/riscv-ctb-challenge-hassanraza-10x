# challenge3_illegal

## Error Description

When the test executes an illegal instruction. It gets stuck and never exits spike.

![error](/images/illegal_error.png)

## Cause

On executing the illegal instruction, the test jumps to `trap_vector` and here it checks whether the exception was due to an environment call or not. As, in our case the cause was not an evnironment call, so the test jumps to `mtvec_handler`.

In `mtvec_handler`, the test makes sure that the cause was an `illegal instruction` with the help of a self check and then jumps to the address stored in `mepc`, which is the address of the same illegal instruction. Thus, our test again and again runs the same illegal instruciton followed by trap handler code and remains in this loop.

## Solution

In `mtvec_handler`, after making it sure that the cause of the exception was an `illegal instruction`. The test should update the value of the `mepc` by `8` (as there are no compressed insturctions so we don't need to check the two least significant bits to know about the length of the instruction) and then execute `mret`.

After this instruction which reads the value of `mepc` register in `mtvec_handler`.
- `csrr t0, mepc`

I have added these two instructions to increment the address in mepc by `8`.
- `addi t0, t0, 8`
- `csrw mepc, t0`

![solution](/images/fix_illegal.png)