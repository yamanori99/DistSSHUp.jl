# Tests

How this repo tests DistSSHUp. Maintainer checklist:
[CONTRIBUTING.md](../CONTRIBUTING.md).

## Run

From the package root:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

That is `test/runtests.jl`. Aqua is a separate CI job, not `Pkg.test()`.

Real SSH (not part of `Pkg.test()`):

```bash
./testenv/docker-ssh/scripts/up.sh --e2e
```

`test/e2e.jl` reads `juliaup_status_lines` for `child-1`, switches that host with `juliaup_default_host!`, then reads status again for that channel. Details: [`testenv/docker-ssh/README.md`](../testenv/docker-ssh/README.md).
