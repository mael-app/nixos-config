{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Login manager for the VM.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";
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

    wl-clipboard
    grim
    slurp
    pavucontrol
    networkmanagerapplet
  ];

  # Useful for desktop applications that need a polkit authentication agent.
  security.polkit.enable = true;

  # Audio.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
