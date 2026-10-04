"""SSH body: add / update / default `channel` with remote juliaup."""
function _juliaup_align_remote_sh(
        channel::AbstractString;
        candidates::Vector{String} = remote_juliaup_candidates(),
    )::String
    ch = String(channel)
    cq = _remote_sh_quote(ch)
    words = join(_juliaup_candidate_sh_word.(candidates), " ")
    tried = join(candidates, ", ")
    return """
    JU=\"\"
    for c in $words; do
      if [ -x \"\$c\" ]; then
        JU=\"\$c\"
        break
      fi
    done
    if [ -z \"\$JU\" ]; then
      echo \"juliaup not found (tried: $tried)\" >&2
      exit 127
    fi
    default=\$( \"\$JU\" status 2>/dev/null | awk '\$1==\"*\" { print \$2; exit }' )
    if [ \"\$default\" = $cq ]; then
      echo already
      exit 0
    fi
    if ! \"\$JU\" add $cq; then
      if ! \"\$JU\" status 2>/dev/null | grep -F -q $cq; then
        # `$cq` (not raw `$ch`): channel may come from the API; keep it shell-safe.
        printf 'juliaup add %s failed\\n' $cq >&2
        exit 1
      fi
    fi
    \"\$JU\" update $cq || exit \$?
    \"\$JU\" default $cq || exit \$?
    echo ok
    """
end

"""SSH body: `juliaup update` (all installed channels; does not `default`)."""
function _juliaup_update_remote_sh(
        candidates::Vector{String} = remote_juliaup_candidates(),
    )::String
    words = join(_juliaup_candidate_sh_word.(candidates), " ")
    tried = join(candidates, ", ")
    return """
    JU=\"\"
    for c in $words; do
      if [ -x \"\$c\" ]; then
        JU=\"\$c\"
        break
      fi
    done
    if [ -z \"\$JU\" ]; then
      echo \"juliaup not found (tried: $tried)\" >&2
      exit 127
    fi
    \"\$JU\" update || exit \$?
    echo ok
    """
end
