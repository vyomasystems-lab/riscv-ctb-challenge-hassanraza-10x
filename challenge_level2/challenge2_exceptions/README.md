# challenge2_exceptions

## Challenge Description

Create an AAPG config file to generate a test with **10 illegal exceptions** with the correct handler code.

## Proposed Solution

First of all, `Makefile` needed to be updated due to the following reasons

- `-march=rv32g` was given in the risc-v compilation command where, `g == imafd`.
- As `f` is for floating point extension. Therefore, an initialization sequence for floating point registers got inserted in the test by the compiler.
- This sequence caused an extra illegal instruction exception (total in 11,as fcsr is not in rv32i) on spike. Therefore, this needed to be modified.

`-march=rv32g` has been replaced with `-march=rv32i` in `Makefile`.

![makefile](/images/exception_makefile.png)

The solution for creating a config file specific to this challenge is the following.

### Solution

#### Description

The config file has been used from the previous challenge with the following changes init.

- In the `general` section of the config file, custom_trap_handler has been selected by setting `custom_trap_handler: true` as the exceptions will be handled in the `machine mode` and not delegated to lower privilege modes.

`general:`

![true](/images/exception_custom_trap_handler.png)

- As according to riscv-privileged-spec, `exception number 2` corresponds to  `illegal instruction`. Therefore, the `exception-generation` section has been updated with `ecause02: 10` in the config file.

- In the `program-macro`, ecuase02 is set to random `ecause02: "random"` which means the 10 illegal instructions (in our case) will be randomly picked.

![random_exception](/images/exception_yaml_random.png)

#### Issue

There is an problem with this approach as this test is being generated to run on a `rv32i` core (therefore, spike is configured with `--isa=rv32i` flag). So, all the `compressed instructions` are turned off in the config file, but in the `test.disass` file some `illegal instructions` can be seen as `compressed` which are causing the infinite loop.

The detailed analysis of the `custom_trap_handler` code with respect to an illegal instruction exception is as follows.

- In `custom_trap_handler`, the `mepc` is updated on the basis of the `least significant two bits` of the `illegal instruction`.
- `if (illegal_instruction[1:0] == 3) mepc = mepc + 4;`
- `else mepc = mepc + 2;`
- This is in compliance with what riscv-instruction set manual says:

> All the 32-bit instructions in the base ISA have their lowest two bits set to 11.
> The optional compressed 16-bit instruction-set extensions have their lowest two bits equal to 00, 01, or 10.

- risc-v privileged spec says:

> On implementations that support only IALIGN=32, the two low bits (mepc[1:0]) are always zero.

- As, already said above that `spike` is configured with `--isa=rv32i`. Therefore, `mepc` least significant two bits will always be zero (regardless of whatever is written in them).

- Now suppose, there is an `illegal compressed instruction (0x5670)` at `0x8000_0004`  during normal program execution.
- When the illegal instruction is executed then the program flow will be moved to `custom_trap_handler` and `mepc = 8000_0004` will be set.
- In `custom_trap_handler`, at one point , the `least significant two bits` of the illegal instruction are checked and as they are not `11` (considering `0x5670`). So, the illegal instruction will be considered as `compressed`.
- `mepc = mepc + 2` will be performed ,but as mentioned earlier `mepc[1:0]`  will always be `zero` regardless of whatever will be written in those bits on `riv32i`.
- So, `mepc` will be the same `8000_0004 and not 8000_0006`  and now when the `mret` will be executed.
- The `PC` will jump to `mepc` which is again `8000_0004` and this whole cycle will repeat indefinite times causing the test to never exit spike.

For reference, `/workspaces/riscv-ctb-challenge-hassanraza-10x/challenge_level2/challenge2_exceptions/Makefile` can be modified by providing `--seed 1` in `aapg gen` command and it can be seen that `879c` is placed as an illegal instruction in the `test.disass`.

#### Workaround

One of the two given workarounds can solve this problem.

1. As the above issue is `seed` specific. So, I have generated the test using `--seed 2` and no illegal compressed instruction got generated in the 10 random illegal instructions so the test successfully run on spike.
2. Override the `custom_trap_handler` with the user defined code for always updating `mepc = mepc + 4` regardless of the length of the illegal instruction for `norvc` implementations only. (I tried to find the method for overriding the `custom_trap_handler` in the documentation of aapg, but I didn't find any.)



## Conclusion

The solution with workaround1 has been committed for this challenge in order to highlight the underlying issue.

The snapshot of the output.

![solution](/images/exception_solution_pic.png)