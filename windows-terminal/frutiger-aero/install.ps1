#Requires -Version 5.1
<#
.SYNOPSIS
    Install the Frutiger Aero theme for Windows Terminal.

.DESCRIPTION
    Copies the color schemes into the per-user Windows Terminal fragments
    folder. That is enough for the schemes to show up in Settings, and it
    does not edit settings.json.

    Pass -Apply to also set the window theme, the acrylic profile
    defaults, and the tracked sky background. That rewrites settings.json:
    comments are removed, keys may be reordered, and a one-time backup is
    written beside the file as settings.json.frutiger-aero.bak.
    backgroundImage is written as the full path of assets\background.png
    in this checkout, because a relative path would be resolved next to
    settings.json.

.PARAMETER Variant
    System follows the Windows light or dark mode. Light pins the sky
    theme. Dusk pins the deep-water theme.

.PARAMETER Apply
    Merge the window theme and profile appearance into every settings.json
    that is already on this machine.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Apply
#>
[CmdletBinding()]
param(
    [ValidateSet('System', 'Light', 'Dusk')]
    [string]$Variant = 'System',

    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'scripts\TerminalSettings.ps1')
Assert-Windows

$root = $PSScriptRoot
$fragmentSource = Join-Path $root 'fragments\frutiger-aero.json'
$windowPath = Join-Path $root 'theme\window.json'
$appearancePath = Join-Path $root 'theme\appearance.json'

if (-not (Test-Path -LiteralPath $fragmentSource)) {
    throw "Missing $fragmentSource. Run this script from a checkout of the repository."
}

$destDir = Get-FragmentDirectory
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
$destFile = Join-Path $destDir 'frutiger-aero.json'
# Rewrite rather than Copy-Item so the fragment is UTF-8 without a BOM.
$fragmentText = [System.IO.File]::ReadAllText($fragmentSource)
$utf8 = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($destFile, $fragmentText.Trim() + "`r`n", $utf8)
Write-Host "Installed color schemes to $destFile"

if (-not $Apply) {
    Write-Host ''
    Write-Host 'Schemes are installed. Quit Windows Terminal completely, then pick'
    Write-Host '"Frutiger Aero" under Settings, Color schemes.'
    Write-Host 'The tab bar and acrylic glass are not part of a fragment. Run this'
    Write-Host 'again with -Apply, or merge theme\window.json and theme\appearance.json'
    Write-Host 'into settings.json by hand.'
    return
}

$window = Read-JsonFile -Path $windowPath
$appearance = Read-JsonFile -Path $appearancePath
$backgroundImage = Get-ThemeBackgroundImagePath -Root $root
if (-not (Test-Path -LiteralPath $backgroundImage)) {
    throw "Missing $backgroundImage. The background image has to stay in the checkout."
}
$build = Get-WindowsBuild

if ($build -lt 22621) {
    Write-Host "Windows build $build has no Mica. Using a solid tab row instead."
    foreach ($theme in @($window.themes)) {
        $theme.window.useMica = $false
        if ($theme.name -eq 'Frutiger Aero') {
            $theme.tabRow.background = '#A9D7EA'
        }
        else {
            $theme.tabRow.background = '#0E3044'
        }
    }
}

switch ($Variant) {
    'Light' { $themeValue = 'Frutiger Aero' }
    'Dusk' { $themeValue = 'Frutiger Aero Dusk' }
    default { $themeValue = $window.theme }
}

$targets = @(Get-ExistingTerminalSettings)
if ($targets.Count -eq 0) {
    Write-Host ''
    Write-Host 'No settings.json was found. Open Windows Terminal once so it creates'
    Write-Host 'the file, then run this script again with -Apply.'
    return
}

foreach ($target in $targets) {
    Write-Host ''
    Write-Host "Updating $($target.Name)"
    Write-Host $target.Path

    $settings = Read-TerminalSettings -Path $target.Path

    $existingThemes = @()
    if ($settings.PSObject.Properties.Name -contains 'themes' -and $null -ne $settings.themes) {
        $existingThemes = @($settings.themes)
    }
    $incomingNames = @($window.themes | ForEach-Object { $_.name })
    $kept = @($existingThemes | Where-Object { $incomingNames -notcontains $_.name })
    Set-JsonNote -Object $settings -Name 'themes' -Value (@($kept) + @($window.themes))
    Set-JsonNote -Object $settings -Name 'theme' -Value $themeValue

    if (-not ($settings.PSObject.Properties.Name -contains 'profiles') -or $null -eq $settings.profiles) {
        Set-JsonNote -Object $settings -Name 'profiles' -Value ([pscustomobject]@{
                defaults = [pscustomobject]@{}
                list     = @()
            })
    }
    if (-not ($settings.profiles.PSObject.Properties.Name -contains 'defaults') -or $null -eq $settings.profiles.defaults) {
        Set-JsonNote -Object $settings.profiles -Name 'defaults' -Value ([pscustomobject]@{})
    }
    foreach ($prop in $appearance.PSObject.Properties) {
        $value = $prop.Value
        if ($prop.Name -eq 'backgroundImage') {
            $value = $backgroundImage
        }
        # A pinned light theme can use the picture as the pane. The default
        # follows the OS, and Terminal cannot store a second image for dark
        # mode, so that case keeps the faint tint from appearance.json.
        if ($prop.Name -eq 'backgroundImageOpacity' -and $Variant -eq 'Light') {
            $value = 1
        }
        Set-JsonNote -Object $settings.profiles.defaults -Name $prop.Name -Value $value
    }
    Write-Host "Background image: $backgroundImage"

    Save-TerminalSettings -Path $target.Path -Settings $settings
    Write-Host "Applied the $Variant variant."
}

Write-Host ''
if ($Variant -eq 'System') {
    Write-Host 'The tab bar and the color scheme follow Windows light and dark mode.'
    Write-Host 'The sky picture cannot. Terminal has one background image, so it stays a 15% tint in both modes.'
}
elseif ($Variant -eq 'Light') {
    Write-Host 'Pinned to the light theme, including when Windows is in dark mode.'
    Write-Host 'The sky picture is fully opaque. Run again without -Variant to follow the OS.'
}
Write-Host 'Quit Windows Terminal completely, including the tray icon, then open it again.'
Write-Host 'Transparency effects in Windows Settings have to be on, or acrylic stays a flat color.'
