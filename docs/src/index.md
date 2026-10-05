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
julia -m DistSSHUp add 1.13 parent child:host1
julia -m DistSSHUp default 1.13 parent
julia -m DistSSHUp update parent
julia -m DistSSHUp status parent
```

`add` installs a channel. `default` switches to it. `update` with no channel updates every installed channel. `status` prints installed channels. `parent` is this machine. `child:NAME` is SSH. `:N` is ignored.
