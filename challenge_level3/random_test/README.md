# random_test

## Problem Description

Generate a random assembly test to expose the bugs in the given design.

## Solution

A number of different random tests have been generated and run on the `riscv_buggy` to expose the bug by changing the configuations in `rv32i.yaml`. By running, many different regressions with `rv32i.cntrl`, `rv32i.compute`, `rv32i.data` and `sys.csr` instructions, the bug seems to in `rv32i.compute` set of instructions.

The changes in `rv32i.yaml` have been shown in the images below:

![random_1](/images/code_instructions.png)

- `total_instructions:` has been limited to `50` because the error in the buggy instruction starts to corrupt the data of the other correct instruction.
- `custom_trap_handler:true` illegal instruction is also being generated manually in the test. Therefore, this field has been marked as `true`.
- `rel_rv32i.ctrl: 1` This field has already been checked by running with a large amount of control instructions. And, it seems there is no problem with the control instructions. Therefore, a very small ratio is used in this test. 
- `rel_rv32i.data: 5` This field represents the ratio of the load & store instructions in the test. 
- `rel_rv32i.compute: 10` This field represents the ratio of the arithmetic instructions in the test.

`exception-generation:`

![random_2](/images/code_exception.png)

- In `exception-generation` section: `ecause02: 1` field tells that one `illegal instruction` will be generated in the test.
- In `program-macro` section: `ecause02: "csrrw x0,marchid, x0"` field manually selects the illegal instruction.

The following image highlights the mismatch between the log of `spike` and `rtl`:

![mismatch](/images/error_screenshot.png)

1. The mismatch at `PC == 0x80000508` represents the mismatch of the result of `ori` operation.
2. The mismatch at `PC == 0x800006c0` represents the mismatch of the result of `or` operation.

```
ORI
< 3 0x80000508 (0x0721ee13) x28 0xe2013fe7
---
> 3 0x80000508 (0x0721ee13) x28 0xe2013ff7

OR
< 3 0x800006c0 (0x017becb3) x25 0x00000000
---
> 3 0x800006c0 (0x017becb3) x25 0x00012000
```

However, the mismatch at `PC == 0x800006e8` is also due to another `or` operation.

This test is seed specific and the seed for generating the same random test is `--seed 2`.

### Result
Hence with the help of the random test, one more bug (`ori`) has been exposed along with the bug in `or` instruction.