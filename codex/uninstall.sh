#!/usr/bin/env bash
# Removes the Big Five for AI from Codex: the skill folder, and the marked block in Codex's global instructions.
# The file is restored byte for byte to what it was before install.sh, using what the start marker recorded.
set -euo pipefail

skill_dir="${HOME}/.agents/skills/big-five-for-ai"
codex_home="${CODEX_HOME:-${HOME}/.codex}"
start_tag="<!-- big-five-for-ai:start"
end_tag="<!-- big-five-for-ai:end -->"

rm -rf "${skill_dir}"
echo "Removed ${skill_dir}"

for instructions in "${codex_home}/AGENTS.md" "${codex_home}/AGENTS.override.md"; do
  [ -f "${instructions}" ] || continue
  text="$(cat "${instructions}"; printf x)"
  text="${text%x}"
  case "${text}" in *"${start_tag}"*) ;; *) continue ;; esac
  nl=$'\n'
  case "${text}" in *$'\r\n'*) nl=$'\r\n' ;; esac

  before="${text%%"${start_tag}"*}"
  marker="${text#*"${start_tag}"}"
  marker="${marker%%-->*}"
  after="${text#*"${end_tag}"}"
  after="${after#"${nl}"}"

  added="${marker#*added=\"}"
  added="${added%%\"*}"
  case "${added}" in 0|1|2) ;; *) added=0 ;; esac
  for ((i = 0; i < added; i++)); do
    before="${before%"${nl}"}"
  done

  result="${before}${after}"
  if [ -z "${result}" ] && [ "${marker#*created=\"yes\"}" != "${marker}" ]; then
    rm -f "${instructions}"
    echo "Removed ${instructions}, which install.sh had created"
  else
    printf '%s' "${result}" > "${instructions}"
    echo "Removed the block from ${instructions}"
  fi
done
