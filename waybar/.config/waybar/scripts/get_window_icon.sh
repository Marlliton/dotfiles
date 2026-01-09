#!/bin/bash

# Get the active window information
window_info=$(hyprctl activewindow -j)

# Extract window class and title
window_class=$(echo "$window_info" | jq -r '.class')
window_title=$(echo "$window_info" | jq -r '.title')

# Default icon
icon="" # A generic application icon

# Map window classes to Nerd Font icons
case "$window_class" in
"kitty" | "Alacritty")
  icon="" # Terminal icon
  ;;
"firefox" | "brave" | "chromium" | "google-chrome")
  icon="" # Browser icon
  ;;
"Code")
  icon="" neovim
  ;;
"telegram-desktop")
  icon="" # Telegram icon
  ;;
"discord")
  icon=" Discord" # Discord icon
  ;;
"spotify" | "Spotify")
  icon="" # Spotify icon
  ;;
"Thunar" | "Pcmanfm")
  icon="" # Folder icon
  ;;
"obsidian")
  icon="" # Obsidian icon
  ;;
"org.gnome.Nautilus")
  icon="" # Nautilus icon
  ;;
"org.kde.dolphin")
  icon="" # Dolphin icon
  ;;
  # Add more mappings as needed
esac

# Output the icon and title. Handle cases where the title might be empty.
if [ -n "$window_title" ]; then
  echo "$icon $window_title"
else
  echo "$icon" # Show only icon if title is empty
fi

