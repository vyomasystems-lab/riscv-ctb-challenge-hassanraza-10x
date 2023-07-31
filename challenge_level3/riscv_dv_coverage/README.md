# riscv_dv_coverage

## Challenge Description

The challenge is to fix the tool problem in generating coverage and make rv32i ISA coverage 100%.

## Tool issue

After generating the `riscv_arithmetic_basic_test` and spike log using the command:

```
run --target rv32i --test riscv_arithmetic_basic_test --testlist testlist.yaml --simulator pyflow
```
The following command was run for extracting the coverage.

```
cov --dir out_2023-07-30/spike_sim/ --simulator=pyflow --enable_visualization --target rv32i
```

In the result of the above mentioned command, the following error appeared in the terminal.

![error 1](/images/first_error.png)

### Solution

When the `cov` command again ran with the `--verbose` flag. It was observed that the error was getting generated due to a piece of code **at line 330** in `run.py`.

That piece of code was `cmd += "+disable_compressed_instr=1 "` and when the arguments that `riscv_instr_cov_test.py` file takes was observed. It was seen that instead of `+disable_compressed_instr=1`, the argument must be `--disable_compressed_instr=1`.

I have updated the `run.py` file and it can be seen in the image that line 330 now contains `--` prefix instead of `+`.

![error 1](/images/line_330.png)

The change in the above mentioned line resolved the tool problem and coverage report could be generated afterward.

## RISCV-DV Issue

In order to hit maximum coverpoints, a randomized test was needed containing branch, load and store instructions, but the problem arose when the tests other than `riscv_arithmetic_basic_test` were passed to the `run` command.

The two problems faced while generating random tests are the following:

### Issue1 (Generator timeout)

When `riscv_rand_instr_test` was passed as an argument to the `run` command. The generator was timing out with a message similar to `lib.py:121 ERROR Timeout[1000s]:`

#### Solution

In order to increase the timeout of the riscv-dv generator, the following flag `--gen_timeout=10000` was added in the `run` command.

### Issue2 (CRITICAL error)

This error hindered the generation of the random test and an issue is already opened on riscv-dv repository [issue-928](https://github.com/chipsalliance/riscv-dv/issues/928) which means a test including conditonal and unconditional jumps instructions (and might be some other as well) is not possible with this generator as of now.

![error 3](/images/image%20(6).png)


### Workaround

In order to extract the coverage, only the spike log was needed. Therefore, **AAPG** has been used as a subsitute of **riscv-dv generator** to generate the random test. The reason for choosing **AAPG** lies in the follwing facts:

1. **AAPG** is very very fast as compared with the **riscv-dv generator**.
2. Using **AAPG**, any conditional and unconditional instructions can be easily generated.

The `Makefile` and `rv32i.yaml` for the generation of the random tests are in current directory.

## Coverage

The command that is used for extracting the coverage is as follows:

```
cov --dir work/log --simulator=pyflow --enable_visualization --target rv32i
```

where the directory of the spike log is `--dir work/log`.

### Issue1

When the above mentioned `cov` was run, the following error was observed in `sim_riscv_instr_cov_test_0_0.log`:

![error 4](/images/error_sh.png)

The error in the image above showed that the coverage file was expecting the `immediate` value to be an register.

The same behavior was happending with `lw` instruction.

#### Solution

In `riscv_cov_instr.py` file, this was the piece of code due to which the `lw` operands problem arose.

![error lw](/images/load_error.png)

 The following changes were made to correct the above mentioned errors. As it can be seen that the error was due to the wrong assignment of the operands. Simply swapping the operand 1 with operand 2 resolved the problem.

For `lw`

![solution 1](/images/updated_riscv_cov_instr.png)


The same change has been done here.

For `sh`

![solution 2](/images/riscv_cov_instr_sh.png)

### Issue2

In `CoverageReport.txt` file, the coverage of **all load and store** instructions is missing. This is because the covergroup inheritance is broken and hence there is no support for **load and store** covergroups.

`riscv_instr_cover_group.py`:

![issue 2_1](/images/riscv_instr_cover_group_broken.png)

`sim_riscv_instr_cov_test_0_0.log`:

![issue 2_2](/images/no_lw_cg_in_log.png)

### Conclusion

Hence, the coverage has been extracted by the tool without using the **load and store** and some other instructions.Therefore, 100% coverage for rv32i is not possible with this tool.

A snapshot of the coverage report:

![coverage 1](/images/coverage.png)

The path of the coverage report is as follows:

```
/workspaces/riscv-ctb-challenge-hassanraza-10x/challenge_level3/riscv_dv_coverage/cov_out_2023-07-31/CoverageReport.txt
```
