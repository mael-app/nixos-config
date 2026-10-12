{ pkgs, config, ... }:

let
  sdk = pkgs.dotnet-sdk_10;
in
{
  home.packages = [ sdk ];

  home.sessionVariables = {
    # Rider and global tools look for the SDK here rather than on the path.
    DOTNET_ROOT = "${sdk}/share/dotnet";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };

  # `dotnet tool install --global` puts its launchers here.
  home.sessionPath = [ "${config.home.homeDirectory}/.dotnet/tools" ];
}
