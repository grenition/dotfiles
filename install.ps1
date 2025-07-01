# Windows entry-point

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
& "$RepoRoot\setup\windows\vim.ps1"

Write-Host "Dotfiles setup done."
