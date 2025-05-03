# p2d - A Pseudo-Boolean d-DNNF Compiler
Our tool p2d can be used for d-DNNF compilation or model counting on a pseudo-Boolean formula.
A pseudo-Boolean formula is a conjunction of inequalities following the structure seen below.

$$\sum_{i=1}^n a_i \cdot v_i \geq b$$

Here, $a_i$ and b are numeric constants and $v_i$ are oolean variables. Pseudo-Boolean formulas are a generalization of CNFs as each clause $(v_1 \vee \ldots \vee v_n)$ can be represented as $\sum_{i=1}^n 1 \cdot v_i \geq 1$.

# Building

## Dependencies
In general, the dependencies are managed with cargo.
For hypergraph partioning, p2d uses the patoh library which cannot directly include it due to licensing issues. To also use patoh follow these steps:
1. Download [patoh](https://faculty.cc.gatech.edu/~umit/software.html)
2. Read the license of patoh and check if you comply to it.
3. Put the patoh directory in a lib directory. The path should be `<PROJECT_ROOT>/lib/patoh/`

## Compiling
Compile the project: `cargo build --release`

# Running
Compile a d-DNNF: `p2d /file.opb -m ddnnf -o file.nnf`

Perform model counting: `p2d /file.opb -m mc`

Print help: `p2d -h`

## Input format
Our compiler p2d takes pseudo-Boolean formulas in the *.opb* format as input.

Consider this small example for a pseudo-Boolean formula in the *.opb* format:
```
# variable = 7 # constraint = 2
x + 2 a + b + c >= 3;
-d -2 * f + 1 * " var_name !" >= 1;
```

For more details, check the [grammar](https://github.com/TUBS-ISF/p2d/blob/main/src/parsing/opb.pest) we use.

