#Requires -Version 7.0
# Remove o Fragment do scheme. Alterações no settings.json voltam restaurando o backup .bak-* criado pelo install.ps1.
$fragmentDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\Solacula'
if (Test-Path $fragmentDir) { Remove-Item -Recurse -Force $fragmentDir; Write-Host 'Fragment Solacula removido.' }
