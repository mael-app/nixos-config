{ pkgs, ... }:

# System-wide so that fontconfig resolves them for every user, not just the
# desktop account. Noto Sans is what the Home Manager GTK theme asks for, and
# the Nerd Font is what waybar, kitty and the power menu are styled with.
{
  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
}
