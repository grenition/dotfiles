#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

# Keyboard
defaults write NSGlobalDomain TISRomanSwitchState -int 1
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# Desktop
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
killall Dock

echo "MacOs configuration installed"
