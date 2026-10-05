# DistSSHUp.jl

[English](README.md) | [日本語](README.ja.md)

<!-- markdownlint-disable MD013 -->
[![Test](https://img.shields.io/github/actions/workflow/status/yamanori99/DistSSHUp.jl/CI.yml?branch=main&style=flat-square&logo=githubactions&logoColor=white&label=Test)](https://github.com/yamanori99/DistSSHUp.jl/actions/workflows/CI.yml)
[![docs-stable](https://img.shields.io/badge/docs-stable-blue?style=flat-square&logo=gitbook&logoColor=white)](https://yamanori99.github.io/DistSSHUp.jl/stable/)
[![docs-dev](https://img.shields.io/badge/docs-dev-blue?style=flat-square&logo=gitbook&logoColor=white)](https://yamanori99.github.io/DistSSHUp.jl/dev/)
[![Julia 1.13+](https://img.shields.io/badge/Julia-1.13+-9558B2?style=flat-square&logo=julia&logoColor=white)](https://yamanori99.github.io/DistSSHKit.jl/stable/requirements/)
[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
<!-- markdownlint-enable MD013 -->

DistSSHUp aligns a host's Julia channel with juliaup: `add`, `update`, and `default`.

Add this package directly. [DistSSHKit](https://github.com/yamanori99/DistSSHKit.jl) users can run the same alignment with `julia -m DistSSHKit up`.

Supported on **macOS, Linux, and WSL2 Ubuntu** (not native Windows).

## Install

```julia
pkg> add DistSSHUp
```

Julia **1.13+**. The host needs **`ssh`** and **`juliaup`**.

```text
julia -m DistSSHUp parent child:host1
julia -m DistSSHUp update parent
```

`parent` is this machine. `child:NAME` is SSH. `:N` is ignored. `update` runs `juliaup update` and leaves the default.

## Documentation

<https://yamanori99.github.io/DistSSHUp.jl/stable/>
