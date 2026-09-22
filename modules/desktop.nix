{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Use the recommended Hyprland launcher rather than invoking Hyprland
  # directly. This avoids the "started without start-hyprland" warning.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/start-hyprland";
        user = "mael";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    spotify

    kitty
    waybar
    rofi
    dunst
    thunar

    wl-clipboard
    grim
    slurp
    pavucontrol
    networkmanagerapplet
  ];

  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
