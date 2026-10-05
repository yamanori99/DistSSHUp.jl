# DistSSHUp

```@meta
CurrentModule = DistSSHUp
```

Align a host's Julia channel with juliaup: `add`, `update`, and `default`.

Add DistSSHUp directly. DistSSHKit users can run the same alignment with `julia -m DistSSHKit up`.

## Install

```julia
using Pkg
Pkg.add("DistSSHUp")
```

Julia 1.13 or later. The host needs `ssh` and `juliaup`. Supported on macOS, Linux, and WSL2 Ubuntu (not native Windows).

## Commands

```text
julia -m DistSSHUp parent child:host1
julia -m DistSSHUp update parent
```

`parent` is this machine. `child:NAME` is SSH. `:N` is ignored. `update` runs `juliaup update` and leaves the default.
