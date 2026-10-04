"""
DistSSHUp — juliaup `add` / `update` / `default` for a DistSSHKit host.

Where juliaup lives is DistSSHBase. Setup progress and confirm text stay in DistSSHRun.
Users add DistSSHKit. This package is a trial and is not registered.
"""
module DistSSHUp

import DistSSHBase
import DistSSHBase:
    _host_sync_remote_shell_cmd,
    _juliaup_candidate_sh_word,
    _local_julia_beside_juliaup,
    _remote_sh_quote,
    _remote_shell_path_word,
    find_local_juliaup,
    local_juliaup_candidates,
    parse_julia_version,
    remote_juliaup_candidates

export julia_version_mismatch_kind
export juliaup_align_host!
export juliaup_align_local!
export juliaup_channel
export juliaup_default_patch
export juliaup_parent_behind_channel
export juliaup_update_host!
export juliaup_update_local!

include("DistSSHUp/version.jl")
include("DistSSHUp/status.jl")
include("DistSSHUp/remote.jl")
include("DistSSHUp/local.jl")
include("DistSSHUp/hosts.jl")
include("DistSSHUp/main.jl")

Base.eval(@__MODULE__, :(@main))

end
