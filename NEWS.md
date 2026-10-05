# News

User-facing changes.
GitHub Releases may copy these sections (`Release notes:` on
`@JuliaRegistrator register`).

## Unreleased

## 0.1.0

First release. Julia **1.13+**.

- Align a host's Julia channel with juliaup: `add`, `default`, `update`, and `status`.
- Add DistSSHUp directly. DistSSHKit users can run `julia -m DistSSHKit up`.
- `add` installs a channel. `default` switches to it. `update` with no channel updates every installed channel and does not change the default. `status` prints installed channels.
- `juliaup_add_local!` and `juliaup_default_local!` are public, same as `juliaup_update_local!`.
- A successful `default` drops the cached Julia path for that host.
