#Requires -Version 7.0
<#
.SYNOPSIS
    Instala o tema Solacula Glass no Windows Terminal.
.DESCRIPTION
    Sem parâmetros: instala apenas o color scheme via Fragment (não toca no settings.json).
    -ProfileName: aplica scheme + acrylic ao perfil informado (ex.: "Ubuntu").
    -WindowTheme: aplica também o tema da janela/abas (afeta todos os perfis).
    Sempre cria backup do settings.json antes de alterar.
.EXAMPLE
    ./install.ps1 -ProfileName "Ubuntu" -WindowTheme
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$ProfileName,
    [switch]$WindowTheme
)
$ErrorActionPreference = 'Stop'
$theme = Get-Content -Raw (Join-Path $PSScriptRoot 'solacula-glass.json') | ConvertFrom-Json -AsHashtable

# 1. Color scheme via Fragment — mecanismo oficial, reversível apagando a pasta
$fragmentDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\Solacula'
New-Item -ItemType Directory -Force -Path $fragmentDir | Out-Null
@{ schemes = $theme.schemes } | ConvertTo-Json -Depth 10 | Set-Content -Encoding utf8 (Join-Path $fragmentDir 'solacula.json')
Write-Host "Scheme 'Solacula Glass' instalado em $fragmentDir"

if (-not $ProfileName -and -not $WindowTheme) { return }

# 2. Perfil e tema da janela exigem editar o settings.json (Fragments não suportam themes)
$candidates = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)
$settingsPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $settingsPath) { throw 'settings.json do Windows Terminal não encontrado.' }

$backup = "$settingsPath.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
Copy-Item $settingsPath $backup
Write-Host "Backup: $backup"

$settings = Get-Content -Raw $settingsPath | ConvertFrom-Json -AsHashtable

if ($ProfileName) {
    $target = $settings.profiles.list | Where-Object { $_.name -eq $ProfileName } | Select-Object -First 1
    if (-not $target) { throw "Perfil '$ProfileName' não encontrado. Perfis: $($settings.profiles.list.name -join ', ')" }
    foreach ($k in $theme.profileSettings.Keys) { $target[$k] = $theme.profileSettings[$k] }
    Write-Host "Perfil '$ProfileName' atualizado."
}

if ($WindowTheme) {
    if (-not $settings.ContainsKey('themes')) { $settings.themes = @() }
    $settings.themes = @($settings.themes | Where-Object { $_.name -ne 'Solacula Glass' }) + $theme.themes
    foreach ($k in $theme.globalSettings.Keys) { $settings[$k] = $theme.globalSettings[$k] }
    Write-Host "Tema de janela 'Solacula Glass' aplicado."
}

if ($PSCmdlet.ShouldProcess($settingsPath, 'Gravar settings.json')) {
    $settings | ConvertTo-Json -Depth 20 | Set-Content -Encoding utf8 $settingsPath
}
