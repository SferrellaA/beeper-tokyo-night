# Shared helpers for install.ps1 and uninstall.ps1.
# Windows PowerShell 5.1 and PowerShell 7.

$script:ThemeNames = @('Frutiger Aero', 'Frutiger Aero Dusk')
$script:BackupSuffix = '.frutiger-aero.bak'

function Assert-Windows {
    if ($env:OS -ne 'Windows_NT') {
        throw 'This script only runs on Windows, where Windows Terminal is installed.'
    }
}

function Get-FragmentDirectory {
    return (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\FrutigerAero')
}

function Get-ThemeBackgroundImagePath {
    param([Parameter(Mandatory)][string]$Root)
    # settings.json cannot use a path relative to this checkout. Terminal
    # resolves a relative backgroundImage next to settings.json, not next
    # to the repository.
    return [System.IO.Path]::GetFullPath((Join-Path $Root 'assets\background.png'))
}

function Test-SamePath {
    param([string]$Left, [string]$Right)
    if ([string]::IsNullOrWhiteSpace($Left) -or [string]::IsNullOrWhiteSpace($Right)) {
        return $false
    }
    try {
        $Left = [System.IO.Path]::GetFullPath($Left)
        $Right = [System.IO.Path]::GetFullPath($Right)
    }
    catch {
        return $false
    }
    return [string]::Equals($Left, $Right, [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-TerminalSettingsCandidates {
    return @(
        @{
            Name = 'Windows Terminal'
            Path = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
        },
        @{
            Name = 'Windows Terminal Preview'
            Path = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'
        },
        @{
            Name = 'Windows Terminal (unpackaged)'
            Path = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json'
        }
    )
}

function Get-ExistingTerminalSettings {
    # Write matches to the pipeline. Returning @() from a function unwraps an
    # empty result into $null, and the caller's @() then counts that as one item.
    Get-TerminalSettingsCandidates | Where-Object { Test-Path -LiteralPath $_.Path }
}

function Read-JsonFile {
    param([Parameter(Mandatory)][string]$Path)
    $text = [System.IO.File]::ReadAllText($Path)
    return ($text | ConvertFrom-Json)
}

function ConvertFrom-JsonC {
    param([Parameter(Mandatory)][string]$Text)

    $stripped = Remove-JsonComments -Text $Text
    $stripped = Remove-TrailingCommas -Text $stripped
    try {
        return ($stripped | ConvertFrom-Json)
    }
    catch {
        throw "settings.json is not valid JSON after removing comments and trailing commas. $($_.Exception.Message)"
    }
}

function Remove-JsonComments {
    param([Parameter(Mandatory)][string]$Text)

    $chars = $Text.ToCharArray()
    $sb = New-Object System.Text.StringBuilder $chars.Length
    $inString = $false
    $escape = $false
    $i = 0
    while ($i -lt $chars.Length) {
        $c = $chars[$i]
        if ($inString) {
            [void]$sb.Append($c)
            if ($escape) {
                $escape = $false
            }
            elseif ($c -eq '\') {
                $escape = $true
            }
            elseif ($c -eq '"') {
                $inString = $false
            }
            $i++
            continue
        }

        if ($c -eq '"') {
            $inString = $true
            [void]$sb.Append($c)
            $i++
            continue
        }

        if ($c -eq '/' -and ($i + 1) -lt $chars.Length) {
            $next = $chars[$i + 1]
            if ($next -eq '/') {
                $i += 2
                while ($i -lt $chars.Length -and $chars[$i] -ne "`n" -and $chars[$i] -ne "`r") {
                    $i++
                }
                continue
            }
            if ($next -eq '*') {
                $i += 2
                while (($i + 1) -lt $chars.Length -and -not ($chars[$i] -eq '*' -and $chars[$i + 1] -eq '/')) {
                    $i++
                }
                if (($i + 1) -ge $chars.Length) {
                    throw 'Unclosed block comment in settings.json.'
                }
                $i += 2
                continue
            }
        }

        [void]$sb.Append($c)
        $i++
    }

    if ($inString) {
        throw 'Unclosed string in settings.json.'
    }
    return $sb.ToString()
}

function Remove-TrailingCommas {
    param([Parameter(Mandatory)][string]$Text)

    $chars = $Text.ToCharArray()
    $sb = New-Object System.Text.StringBuilder $chars.Length
    $inString = $false
    $escape = $false
    $i = 0
    while ($i -lt $chars.Length) {
        $c = $chars[$i]
        if ($inString) {
            [void]$sb.Append($c)
            if ($escape) {
                $escape = $false
            }
            elseif ($c -eq '\') {
                $escape = $true
            }
            elseif ($c -eq '"') {
                $inString = $false
            }
            $i++
            continue
        }

        if ($c -eq '"') {
            $inString = $true
            [void]$sb.Append($c)
            $i++
            continue
        }

        if ($c -eq ',') {
            $j = $i + 1
            while ($j -lt $chars.Length -and [char]::IsWhiteSpace($chars[$j])) {
                $j++
            }
            if ($j -lt $chars.Length -and ($chars[$j] -eq '}' -or $chars[$j] -eq ']')) {
                $i++
                continue
            }
        }

        [void]$sb.Append($c)
        $i++
    }
    return $sb.ToString()
}

function Read-TerminalSettings {
    param([Parameter(Mandatory)][string]$Path)
    $text = [System.IO.File]::ReadAllText($Path)
    return ConvertFrom-JsonC -Text $text
}

function Format-JsonString {
    param([Parameter(Mandatory)][string]$Text)
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('"')
    foreach ($char in $Text.ToCharArray()) {
        $code = [int]$char
        if ($char -eq '"') { [void]$sb.Append('\"') }
        elseif ($char -eq '\') { [void]$sb.Append('\\') }
        elseif ($char -eq "`b") { [void]$sb.Append('\b') }
        elseif ($char -eq "`f") { [void]$sb.Append('\f') }
        elseif ($char -eq "`n") { [void]$sb.Append('\n') }
        elseif ($char -eq "`r") { [void]$sb.Append('\r') }
        elseif ($char -eq "`t") { [void]$sb.Append('\t') }
        elseif ($code -lt 32) { [void]$sb.Append(('\u{0:x4}' -f $code)) }
        else { [void]$sb.Append($char) }
    }
    [void]$sb.Append('"')
    return $sb.ToString()
}

function Test-JsonNumber {
    param($Value)
    return ($Value -is [byte] -or $Value -is [int16] -or $Value -is [int32] -or $Value -is [int64] -or
        $Value -is [sbyte] -or $Value -is [uint16] -or $Value -is [uint32] -or $Value -is [uint64] -or
        $Value -is [decimal] -or $Value -is [double] -or $Value -is [single])
}

function Format-JsonNumber {
    param($Value)
    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    if ($Value -is [double] -or $Value -is [single]) {
        if ([double]::IsNaN($Value) -or [double]::IsInfinity($Value)) {
            throw 'Refusing to rewrite settings.json because it contains a non-finite number.'
        }
        return $Value.ToString('R', $culture)
    }
    if ($Value -is [decimal]) {
        return $Value.ToString($culture)
    }
    return [System.Convert]::ToString($Value, $culture)
}

# Windows PowerShell 5.1 ConvertTo-Json turns a one-item array into a bare
# object. settings.json is full of one-item arrays, so this writer is used
# instead. Every IList becomes a JSON array, including arrays of length 1.
function ConvertTo-JsonText {
    param($Value, [int]$Level = 0)

    if ($Level -gt 100) {
        throw 'Refusing to rewrite settings.json because it is nested more than 100 levels.'
    }
    if ($null -eq $Value) { return 'null' }
    if ($Value -is [bool]) {
        if ($Value) { return 'true' } else { return 'false' }
    }
    if ($Value -is [string]) { return (Format-JsonString $Value) }
    if (Test-JsonNumber $Value) { return (Format-JsonNumber $Value) }
    if ($Value -is [System.Collections.IDictionary]) { return (Format-JsonDictionary $Value $Level) }
    if ($Value -is [System.Collections.IList]) { return (Format-JsonArray $Value $Level) }
    if ($Value -is [psobject]) { return (Format-JsonObject $Value $Level) }

    throw "Refusing to rewrite settings.json. Unsupported value type: $($Value.GetType().FullName)"
}

function Format-JsonObject {
    param($Value, [int]$Level)
    $props = @($Value.PSObject.Properties | Where-Object { $_.MemberType -eq 'NoteProperty' })
    return (Format-JsonMembers $props $Level)
}

function Format-JsonDictionary {
    param($Value, [int]$Level)
    $props = New-Object System.Collections.Generic.List[object]
    foreach ($key in @($Value.Keys)) {
        $props.Add([pscustomobject]@{ Name = [string]$key; Value = $Value[$key] })
    }
    return (Format-JsonMembers $props $Level)
}

function Format-JsonMembers {
    param($Props, [int]$Level)
    $items = @($Props)
    if ($items.Count -eq 0) { return '{}' }
    $pad = ' ' * (($Level + 1) * 4)
    $close = ' ' * ($Level * 4)
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($prop in $items) {
        $rendered = ConvertTo-JsonText -Value $prop.Value -Level ($Level + 1)
        $lines.Add($pad + (Format-JsonString ([string]$prop.Name)) + ': ' + $rendered)
    }
    return "{`r`n" + ($lines -join ",`r`n") + "`r`n" + $close + '}'
}

function Format-JsonArray {
    param($Value, [int]$Level)
    $items = @($Value)
    if ($items.Count -eq 0) { return '[]' }
    $pad = ' ' * (($Level + 1) * 4)
    $close = ' ' * ($Level * 4)
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($item in $items) {
        $lines.Add($pad + (ConvertTo-JsonText -Value $item -Level ($Level + 1)))
    }
    return "[`r`n" + ($lines -join ",`r`n") + "`r`n" + $close + ']'
}

function Write-TerminalSettings {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$Settings
    )
    $json = ConvertTo-JsonText -Value $Settings
    $encoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $json + "`r`n", $encoding)
}

function Save-TerminalSettings {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)]$Settings
    )
    Backup-TerminalSettings -Path $Path | Out-Null
    $snapshot = $Path + '.frutiger-aero.tmp'
    Copy-Item -LiteralPath $Path -Destination $snapshot -Force
    try {
        Write-TerminalSettings -Path $Path -Settings $Settings
        $null = Read-TerminalSettings -Path $Path
    }
    catch {
        Copy-Item -LiteralPath $snapshot -Destination $Path -Force
        Remove-Item -LiteralPath $snapshot -Force -ErrorAction SilentlyContinue
        throw
    }
    Remove-Item -LiteralPath $snapshot -Force
}

function Backup-TerminalSettings {
    param([Parameter(Mandatory)][string]$Path)
    $backup = $Path + $script:BackupSuffix
    if (-not (Test-Path -LiteralPath $backup)) {
        Copy-Item -LiteralPath $Path -Destination $backup
        Write-Host "Backed up settings to $backup"
    }
    return $backup
}

function Set-JsonNote {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name,
        $Value
    )
    if ($Object.PSObject.Properties.Name -contains $Name) {
        $Object.$Name = $Value
    }
    else {
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    }
}

function Remove-JsonNote {
    param(
        [Parameter(Mandatory)]$Object,
        [Parameter(Mandatory)][string]$Name
    )
    if ($Object.PSObject.Properties.Name -contains $Name) {
        $Object.PSObject.Properties.Remove($Name)
    }
}

function Get-WindowsBuild {
    $build = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild
    return [int]$build
}
