# directed_test

## Challenge Description

Write a directed assembly test that can expose the bug in the given design.

## Solution

To expose the bug in the given design using the directed test, each supported instruction in rv32i needed to be tested manually. As a starting point, I started writing the test for `R-type` instructions in *test.S*

I added the test cases for each `R-type` instruction in *test.S*.

![test.S](/images/code_change.png)

The test ran successfully on `spike`, but **test number 4** got failed on the given design indicating that there is an issue with `or` operation.

Mismatch in spike and RTL log can be seen in the following image.

![mismatch](/images/challenge3_directed_mismatch.png)

On spike, the `or` operation has generated `0x0dfbffbf`, which is the correct result. While, on the given design `0x0df25d05` has been generated which is not correct.


```
< 3 0x8000014c (0x0020ef33) x30 0x0df25d05
---
> 3 0x8000014c (0x0020ef33) x30 0x0dfbffbf
```

### Observation
On observing keenly, it can been seen that `riscv_buggy` is generating the result of `or` operation as if it was an `xor` operation. As, the expected result of the `xor` operation is indeed `0x0df25d05` and `riscv_buggy` has generated the same result for `or`. It could be an issue either in `ALU` or `Decode` stage.
