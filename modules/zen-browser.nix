{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.my.zen-browser;

  extension = shortId: guid: {
    name = guid;
    value = {
      install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
      installation_mode = "normal_installed";
    };
  };

  prefs = {
    # Check these out at about:config
    "extensions.autoDisableScopes" = 0;
    "extensions.pocket.enabled" = false;
  };

  extensions = [
    (extension "ublock-origin" "uBlock0@raymondhill.net")
  ];
in
{
  options.my.zen-browser = {
    enable = lib.mkEnableOption "Enable zen-browser with custom configuration.";
    package = lib.mkPackageOption pkgs "zen-browser-unwrapped" { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur =
      { ... }:
      {
        home.packages = [
          (pkgs.wrapFirefox cfg.package {
            extraPrefs = lib.concatLines (
              lib.mapAttrsToList (
                name: value: "lockPref(${lib.strings.toJSON name}, ${lib.strings.toJSON value});"
              ) prefs
            );

            extraPolicies = {
              DisableTelemetry = true;
              ExtensionSettings = builtins.listToAttrs extensions;

              SearchEngines = {
                Default = "@sp";
                Add = [
                  {
                    Name = "Startpage";
                    URLTemplate = "https://www.startpage.com/sp/search?query=%s&cat=web&pl=opensearch&language=english";
                    IconURL = "https://startpage.com/favicon.ico";
                    Alias = "@sp";
                  }
                  {
                    Name = "nixpkgs packages";
                    URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                    IconURL = "https://wiki.nixos.org/favicon.ico";
                    Alias = "@np";
                  }
                  {
                    Name = "NixOS options";
                    URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
                    IconURL = "https://wiki.nixos.org/favicon.ico";
                    Alias = "@no";
                  }
                  {
                    Name = "NixOS Wiki";
                    URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
                    IconURL = "https://wiki.nixos.org/favicon.ico";
                    Alias = "@nw";
                  }
                  {
                    Name = "noogle";
                    URLTemplate = "https://noogle.dev/q?term={searchTerms}";
                    IconURL = "https://noogle.dev/favicon.ico";
                    Alias = "@ng";
                  }
                ];
              };
            };
          })
        ];
      };
  };
}
