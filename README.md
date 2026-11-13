# MyCarComponents

CTU 16ESPD vehicle systems coursework. The coursework folders in the current branch contain the reports, simulation traces, graphs and `TEST_RESULTS.md` tables. The executable models are under `dyad/`. The source notes credit the course examples used in the models. [Course guide](https://dr14-make.github.io/16ESPD/) · [Coursework](coursework/) · [Sources](coursework/SOURCES.md)

## Run the coursework

Open the repository in VS Code with **Dyad Studio 3.5.1**. Its compiler and Julia channel are `3.5.0` (`dyad-3.5.0`). In the Dyad Julia REPL, activate this repository and run `using Pkg; Pkg.instantiate()`. Then run **Dyad: Compile** from the VS Code command palette. The compiler writes the files under `generated/`.

From the repository root in PowerShell, set `$lecture` to the number of a lecture included in this branch and run both scripts. They write CSV, SVG and TOML results in the corresponding `coursework/LectureN/` directory. Use a separate checkout if you want to keep the committed traces available for comparison.

```powershell
$lecture = Read-Host 'Lecture number available on this branch'
$env:JULIA_NUM_PRECOMPILE_TASKS = '1'
$env:JULIA_PKG_PRECOMPILE_AUTO = '0'
$env:GKSwstype = '100'
julia +dyad-3.5.0 --project=. --startup-file=no --pkgimages=no scripts/run_coursework.jl $lecture
julia +dyad-3.5.0 --project=. --startup-file=no --pkgimages=no scripts/run_additional_checks.jl $lecture
```

Check the solver status, final simulation time and numerical assertions in `results.toml`. Use each report for reference comparisons and known limitations.
