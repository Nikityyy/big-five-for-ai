# Installs the Big Five for AI for Codex on Windows (PowerShell 5.1 or 7).
# - The skill goes to ~/.agents/skills/big-five-for-ai/.
# - The principles go into Codex's global instructions file between two marker lines, so every session loads them.
#   Nothing outside the markers changes. The start marker records the separator lines install added, so
#   uninstall.ps1 can restore the file byte for byte.
# Run it again to update. Remove everything with uninstall.ps1.
# The script block keeps its variables and settings out of your session when run with irm | iex.
& {
    $ErrorActionPreference = 'Stop'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $sourceUrl = 'https://raw.githubusercontent.com/Nikityyy/big-five-for-ai/main/skills/big-five-for-ai'
    $skillDir = Join-Path $HOME '.agents/skills/big-five-for-ai'
    $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
    $startTag = '<!-- big-five-for-ai:start'
    $endTag = '<!-- big-five-for-ai:end -->'
    $utf8 = New-Object System.Text.UTF8Encoding $false

    # Codex reads AGENTS.override.md instead of AGENTS.md when the override exists and is not empty.
    $instructions = Join-Path $codexHome 'AGENTS.md'
    $override = Join-Path $codexHome 'AGENTS.override.md'
    if ((Test-Path -LiteralPath $override) -and (Get-Item -LiteralPath $override).Length -gt 0) {
        $instructions = $override
    }

    New-Item -ItemType Directory -Force -Path $skillDir, $codexHome | Out-Null
    foreach ($name in 'SKILL.md', 'EXAMPLES.md') {
        Invoke-WebRequest -UseBasicParsing -Uri "$sourceUrl/$name" -OutFile (Join-Path $skillDir $name)
    }

    # Read the file exactly, keeping a UTF-8 byte order mark if it has one.
    $created = 'no'
    $text = ''
    $bom = $false
    if (Test-Path -LiteralPath $instructions) {
        $bytes = [IO.File]::ReadAllBytes($instructions)
        $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        $offset = if ($bom) { 3 } else { 0 }
        $text = $utf8.GetString($bytes, $offset, $bytes.Length - $offset)
    } else {
        $created = 'yes'
    }
    $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

    # The block: SKILL.md without its frontmatter, with the examples link pointing at the installed copy.
    $skillLines = [IO.File]::ReadAllText((Join-Path $skillDir 'SKILL.md'), $utf8) -split "`r?`n"
    $start = 0
    if ($skillLines[0] -eq '---') {
        $start = [Array]::IndexOf($skillLines, '---', 1) + 1
    }
    while ($start -lt $skillLines.Length -and $skillLines[$start] -eq '') { $start++ }
    $bodyLines = $skillLines[$start..($skillLines.Length - 1)]
    if ($bodyLines[-1] -eq '') { $bodyLines = $bodyLines[0..($bodyLines.Length - 2)] }
    $examplesPath = (Join-Path $skillDir 'EXAMPLES.md').Replace('\', '/')
    $block = (($bodyLines | ForEach-Object { $_.Replace('](EXAMPLES.md)', "]($examplesPath)") }) -join $nl) + $nl

    $index = $text.IndexOf($startTag)
    if ($index -ge 0) {
        # Update: replace the old block and keep what the first install recorded.
        $before = $text.Substring(0, $index)
        $markerEnd = $text.IndexOf('-->', $index)
        $marker = $text.Substring($index + $startTag.Length, $markerEnd - $index - $startTag.Length)
        $endIndex = $text.IndexOf($endTag, $index) + $endTag.Length
        $after = $text.Substring($endIndex)
        if ($after.StartsWith($nl)) { $after = $after.Substring($nl.Length) }
    } else {
        $after = ''
        if ($text -eq '') {
            $before = ''; $added = 0
        } elseif ($text.EndsWith($nl)) {
            $before = $text + $nl; $added = 1
        } else {
            $before = $text + $nl + $nl; $added = 2
        }
        $marker = " added=`"$added`" created=`"$created`" "
    }

    $result = $before + $startTag + $marker + '-->' + $nl + $block + $endTag + $nl + $after
    $out = $utf8.GetBytes($result)
    if ($bom) { $out = [byte[]](0xEF, 0xBB, 0xBF) + $out }
    [IO.File]::WriteAllBytes($instructions, $out)

    Write-Output 'Installed the Big Five for AI for Codex.'
    Write-Output "  Skill:        $skillDir"
    Write-Output "  Instructions: $instructions"
}
