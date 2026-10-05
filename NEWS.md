# News

User-facing changes.
GitHub Releases may copy these sections (`Release notes:` on
`@JuliaRegistrator register`).

## Unreleased

## 0.1.0

First release. Julia **1.13+**.

- Align a host's Julia channel with juliaup: `add`, `update`, and `default`.
- Add DistSSHUp directly. DistSSHKit users can run `julia -m DistSSHKit up`.
- `julia -m DistSSHUp parent child:host1` aligns. `julia -m DistSSHUp update parent` runs `juliaup update` and leaves the default.
