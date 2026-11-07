# Removes the Big Five for AI from Codex on Windows: the skill folder, and the marked block in Codex's
# global instructions. The file is restored byte for byte to what it was before install.ps1, using what
# the start marker recorded.
# The script block keeps its variables and settings out of your session when run with irm | iex.
& {
    $ErrorActionPreference = 'Stop'

    $skillDir = Join-Path $HOME '.agents/skills/big-five-for-ai'
    $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
    $startTag = '<!-- big-five-for-ai:start'
    $endTag = '<!-- big-five-for-ai:end -->'
    $utf8 = New-Object System.Text.UTF8Encoding $false

    if (Test-Path -LiteralPath $skillDir) { Remove-Item -LiteralPath $skillDir -Recurse -Force }
    Write-Output "Removed $skillDir"

    foreach ($instructions in (Join-Path $codexHome 'AGENTS.md'), (Join-Path $codexHome 'AGENTS.override.md')) {
        if (-not (Test-Path -LiteralPath $instructions)) { continue }
        $bytes = [IO.File]::ReadAllBytes($instructions)
        $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        $offset = if ($bom) { 3 } else { 0 }
        $text = $utf8.GetString($bytes, $offset, $bytes.Length - $offset)
        $index = $text.IndexOf($startTag)
        if ($index -lt 0) { continue }
        $nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

        $before = $text.Substring(0, $index)
        $markerEnd = $text.IndexOf('-->', $index)
        $marker = $text.Substring($index + $startTag.Length, $markerEnd - $index - $startTag.Length)
        $endIndex = $text.IndexOf($endTag, $index) + $endTag.Length
        $after = $text.Substring($endIndex)
        if ($after.StartsWith($nl)) { $after = $after.Substring($nl.Length) }

        $added = 0
        if ($marker -match 'added="([012])"') { $added = [int]$Matches[1] }
        for ($i = 0; $i -lt $added; $i++) {
            if ($before.EndsWith($nl)) { $before = $before.Substring(0, $before.Length - $nl.Length) }
        }

        $result = $before + $after
        if ($result -eq '' -and $marker -match 'created="yes"') {
            Remove-Item -LiteralPath $instructions -Force
            Write-Output "Removed $instructions, which install.ps1 had created"
        } else {
            $out = $utf8.GetBytes($result)
            if ($bom) { $out = [byte[]](0xEF, 0xBB, 0xBF) + $out }
            [IO.File]::WriteAllBytes($instructions, $out)
            Write-Output "Removed the block from $instructions"
        }
    }
}
