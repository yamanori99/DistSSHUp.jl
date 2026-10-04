"""Compare two Julia versions and classify the difference:
`:none` (equal), `:minor` (major.minor differs), or `:patch` (patch only)."""
function julia_version_mismatch_kind(
        local_version::VersionNumber,
        remote_version::VersionNumber,
    )::Symbol
    if remote_version.major != local_version.major || remote_version.minor != local_version.minor
        return :minor
    elseif remote_version.patch != local_version.patch
        return :patch
    end
    return :none
end

"""Channel string for juliaup from a Julia `VersionNumber` (`\"1.13\"`)."""
juliaup_channel(v::VersionNumber = VERSION)::String = "$(v.major).$(v.minor)"

"""True when `remote` is the same major.minor as `local` but a newer version."""
function juliaup_parent_behind_channel(
        local_version::VersionNumber,
        remote_version::VersionNumber,
    )::Bool
    julia_version_mismatch_kind(local_version, remote_version) == :minor && return false
    return remote_version > local_version
end
