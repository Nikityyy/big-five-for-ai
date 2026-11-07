#!/usr/bin/env bash
# Installs the Big Five for AI for Codex.
# - The skill goes to ~/.agents/skills/big-five-for-ai/.
# - The principles go into Codex's global instructions file between two marker lines, so every session loads them.
#   Nothing outside the markers changes. The start marker records the separator lines install added, so
#   uninstall.sh can restore the file byte for byte.
# Run it again to update. Remove everything with uninstall.sh.
set -euo pipefail

source_url="https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai"
skill_dir="${HOME}/.agents/skills/big-five-for-ai"
codex_home="${CODEX_HOME:-${HOME}/.codex}"
start_tag="<!-- big-five-for-ai:start"
end_tag="<!-- big-five-for-ai:end -->"

# Codex reads AGENTS.override.md instead of AGENTS.md when the override exists and is not empty.
instructions="${codex_home}/AGENTS.md"
if [ -s "${codex_home}/AGENTS.override.md" ]; then
  instructions="${codex_home}/AGENTS.override.md"
fi

download_dir="$(mktemp -d)"
trap 'rm -rf "${download_dir}"' EXIT
curl -fsSL "${source_url}/SKILL.md" -o "${download_dir}/SKILL.md"
curl -fsSL "${source_url}/EXAMPLES.md" -o "${download_dir}/EXAMPLES.md"
mkdir -p "${skill_dir}" "${codex_home}"
cp "${download_dir}/SKILL.md" "${download_dir}/EXAMPLES.md" "${skill_dir}/"

# Read the file exactly, trailing newlines included.
created="no"
text=""
if [ -f "${instructions}" ]; then
  text="$(cat "${instructions}"; printf x)"
  text="${text%x}"
else
  created="yes"
fi
nl=$'\n'
case "${text}" in *$'\r\n'*) nl=$'\r\n' ;; esac

# The block: SKILL.md without its frontmatter, with the examples link pointing at the installed copy.
block=""
while IFS= read -r line || [ -n "${line}" ]; do
  block+="${line%$'\r'}${nl}"
done < <(awk 'NR == 1 && /^---\r?$/ { front = 1; next } front && /^---\r?$/ { front = 0; next } !front' "${download_dir}/SKILL.md" \
  | sed -e '/./,$!d' -e "s|](EXAMPLES.md)|](${skill_dir}/EXAMPLES.md)|")

case "${text}" in
  *"${start_tag}"*)
    # Update: replace the old block and keep what the first install recorded.
    before="${text%%"${start_tag}"*}"
    marker="${text#*"${start_tag}"}"
    marker="${marker%%-->*}"
    after="${text#*"${end_tag}"}"
    after="${after#"${nl}"}"
    ;;
  *)
    after=""
    if [ -z "${text}" ]; then
      before=""; added=0
    elif [ "${text%"${nl}"}" != "${text}" ]; then
      before="${text}${nl}"; added=1
    else
      before="${text}${nl}${nl}"; added=2
    fi
    marker=" added=\"${added}\" created=\"${created}\" "
    ;;
esac

printf '%s' "${before}${start_tag}${marker}-->${nl}${block}${end_tag}${nl}${after}" > "${instructions}"

echo "Installed the Big Five for AI for Codex."
echo "  Skill:        ${skill_dir}"
echo "  Instructions: ${instructions}"
