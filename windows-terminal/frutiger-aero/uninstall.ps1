#Requires -Version 5.1
<#
.SYNOPSIS
    Remove the Frutiger Aero theme from Windows Terminal.

.DESCRIPTION
    Deletes the per-user fragment, then removes this theme's entries from
    settings.json. A one-time backup is written first if one does not
    already exist.

    Pass -RevertSettings to put back settings.json.frutiger-aero.bak
    instead of editing the current file. That backup is the file from
    before the first -Apply, so later edits in settings.json are lost.

.PARAMETER RevertSettings
    Restore the first backup of settings.json instead of editing it.
#>
[CmdletBinding()]
param(
    [switch]$RevertSettings
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\TerminalSettings.ps1')
Assert-Windows

$destDir = Get-FragmentDirectory
if (Test-Path -LiteralPath $destDir) {
    Remove-Item -LiteralPath $destDir -Recurse -Force
    Write-Host "Removed $destDir"
}
else {
    Write-Host 'No fragment folder was installed.'
}

$root = $PSScriptRoot
$window = Read-JsonFile -Path (Join-Path $root 'theme\window.json')
$appearance = Read-JsonFile -Path (Join-Path $root 'theme\appearance.json')
$ourNames = @($window.themes | ForEach-Object { $_.name })

$targets = @(Get-ExistingTerminalSettings)
if ($targets.Count -eq 0) {
    Write-Host 'No settings.json was found. Nothing else to remove.'
    return
}

foreach ($target in $targets) {
    Write-Host ''
    Write-Host $target.Name
    $backup = $target.Path + $script:BackupSuffix

    if ($RevertSettings) {
        if (-not (Test-Path -LiteralPath $backup)) {
            Write-Host "No backup at $backup. Left settings.json alone."
            continue
        }
        Copy-Item -LiteralPath $backup -Destination $target.Path -Force
        Write-Host "Restored $backup"
        continue
    }

    $settings = Read-TerminalSettings -Path $target.Path
    $changed = $false

    if ($settings.PSObject.Properties.Name -contains 'themes' -and $null -ne $settings.themes) {
        $before = @($settings.themes).Count
        $remaining = @($settings.themes | Where-Object { $ourNames -notcontains $_.name })
        if ($remaining.Count -ne $before) {
            Set-JsonNote -Object $settings -Name 'themes' -Value $remaining
            $changed = $true
        }
    }

    if ($settings.PSObject.Properties.Name -contains 'theme' -and $null -ne $settings.theme) {
        if ($settings.theme -is [string]) {
            if ($ourNames -contains $settings.theme) {
                Set-JsonNote -Object $settings -Name 'theme' -Value 'system'
                $changed = $true
            }
        }
        else {
            $rewrotePair = $false
            foreach ($key in @('light', 'dark')) {
                if ($settings.theme.PSObject.Properties.Name -contains $key -and $ourNames -contains [string]$settings.theme.$key) {
                    $builtIn = $(if ($key -eq 'light') { 'light' } else { 'dark' })
                    $settings.theme.$key = $builtIn
                    $rewrotePair = $true
                    $changed = $true
                }
            }
            $lightIsDefault = ($settings.theme.PSObject.Properties.Name -notcontains 'light') -or ($settings.theme.light -eq 'light')
            $darkIsDefault = ($settings.theme.PSObject.Properties.Name -notcontains 'dark') -or ($settings.theme.dark -eq 'dark')
            if ($rewrotePair -and $lightIsDefault -and $darkIsDefault) {
                Set-JsonNote -Object $settings -Name 'theme' -Value 'system'
            }
        }
    }

    $hasDefaults = $settings.PSObject.Properties.Name -contains 'profiles' -and
        $null -ne $settings.profiles -and
        $settings.profiles.PSObject.Properties.Name -contains 'defaults' -and
        $null -ne $settings.profiles.defaults
    if ($hasDefaults) {
        $defaults = $settings.profiles.defaults
        if ($defaults.PSObject.Properties.Name -contains 'colorScheme') {
            $scheme = $defaults.colorScheme
            $matches = $false
            if ($scheme -is [string]) {
                $matches = $ourNames -contains $scheme
            }
            elseif ($null -ne $scheme) {
                $lightName = [string]$scheme.light
                $darkName = [string]$scheme.dark
                $matches = ($ourNames -contains $lightName) -and ($ourNames -contains $darkName)
            }
            if ($matches) {
                Remove-JsonNote -Object $defaults -Name 'colorScheme'
                $changed = $true
            }
        }

        $acrylicMatches = ($defaults.PSObject.Properties.Name -contains 'useAcrylic') -and
            ($defaults.useAcrylic -eq $appearance.useAcrylic)
        $opacityMatches = ($defaults.PSObject.Properties.Name -contains 'opacity') -and
            ([int]$defaults.opacity -eq [int]$appearance.opacity)
        if ($acrylicMatches -and $opacityMatches) {
            Remove-JsonNote -Object $defaults -Name 'useAcrylic'
            Remove-JsonNote -Object $defaults -Name 'opacity'
            $changed = $true
        }

        $installedImage = Get-ThemeBackgroundImagePath -Root $root
        $imageMatches = ($defaults.PSObject.Properties.Name -contains 'backgroundImage') -and
            (Test-SamePath -Left ([string]$defaults.backgroundImage) -Right $installedImage)
        if ($imageMatches) {
            foreach ($name in @('backgroundImage', 'backgroundImageOpacity', 'backgroundImageStretchMode', 'backgroundImageAlignment')) {
                Remove-JsonNote -Object $defaults -Name $name
            }
            $changed = $true
        }
    }

    if (-not $changed) {
        Write-Host 'No Frutiger Aero settings were found in this file.'
        continue
    }

    Save-TerminalSettings -Path $target.Path -Settings $settings
    Write-Host 'Removed the theme from settings.json.'
}

Write-Host ''
Write-Host 'Quit Windows Terminal completely, then open it again.'
