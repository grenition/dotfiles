$RepoRoot  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$VimrcSrc  = Join-Path $RepoRoot "..\..\config\.vimrc"
$VimrcDest = "$HOME\_vimrc"

Copy-Item -Path $VimrcSrc -Destination $VimrcDest -Force
