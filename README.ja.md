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

DistSSHUp は、ホストの Julia チャンネルを juliaup の `add` / `update` / `default` で揃える。

このパッケージは直接足してよい。[DistSSHKit](https://github.com/yamanori99/DistSSHKit.jl) の利用者は、`julia -m DistSSHKit up` でも同じ揃えができる。

対応は **macOS、Linux、WSL2 Ubuntu** (ネイティブ Windows は対象外)。

## インストール

```julia
pkg> add DistSSHUp
```

Julia **1.13+**。ホストには **`ssh`** と **`juliaup`** が要る。

```text
julia -m DistSSHUp parent child:host1
julia -m DistSSHUp update parent
```

`parent` はこのマシン。`child:NAME` は SSH。`:N` は無視する。`update` は `juliaup update` を実行し、default は変えない。

## ドキュメント

<https://yamanori99.github.io/DistSSHUp.jl/stable/>
