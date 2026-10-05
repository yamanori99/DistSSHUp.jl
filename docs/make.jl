using Documenter
using DistSSHUp

DocMeta.setdocmeta!(DistSSHUp, :DocTestSetup, :(using DistSSHUp); recursive = true)

makedocs(;
    modules = [DistSSHUp],
    authors = "Takanori Yamamoto, Honoka Ampuku, and contributors",
    sitename = "DistSSHUp.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://yamanori99.github.io/DistSSHUp.jl",
        size_threshold_ignore = ["api.md"],
        edit_link = "main",
    ),
    pages = [
        "Introduction" => "index.md",
        "API" => "api.md",
    ],
    checkdocs = :none,
    warnonly = [:missing_docs, :docs_block, :cross_references],
)

deploydocs(;
    repo = "github.com/yamanori99/DistSSHUp.jl.git",
    devbranch = "main",
    push_preview = true,
    versions = ["stable" => "v^", "v#.#", "dev" => "dev"],
)
