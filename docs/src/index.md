# DistSSHUp

```@meta
CurrentModule = DistSSHUp
```

Align a host's Julia channel with juliaup: `add`, `default`, `update`, and `status`.

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
julia -m DistSSHUp update 1.13 child:host1
julia -m DistSSHUp status parent
julia -m DistSSHUp status 1.13 parent
```

`add` installs a channel. `default` switches to it. `update` with no channel updates every installed channel and does not change the default. `status` prints installed channels. `parent` is this machine. `child:NAME` is SSH. `:N` is ignored.

```jldoctest
julia> using DistSSHUp

julia> juliaup_channel(v"1.13.2")
"1.13"

julia> julia_version_mismatch_kind(v"1.13.2", v"1.13.5")
:patch
```
