#!/bin/bash
# Powermenu para o botão de power

# menu=$(echo -e " Lock\n󰍃 Logout\n󰒲 Suspend\n󰜉 Reboot\n󰐥 Shutdown" | rofi -dmenu -p "Power Menu" -theme ~/.config/rofi/powermenu.rasi)
menu=$(echo -e " Lock\n󰍃 Logout\n󰒲 Suspend\n󰜉 Reboot\n󰐥 Shutdown" | rofi -dmenu -p "Power Menu")

case $menu in
" Lock")
  swaylock
  ;;
"󰍃 Logout")
  hyprctl dispatch exit
  ;;
"󰒲 Suspend")
  systemctl suspend
  ;;
"󰜉 Reboot")
  systemctl reboot
  ;;
"󰐥 Shutdown")
  systemctl poweroff
  ;;
esac
