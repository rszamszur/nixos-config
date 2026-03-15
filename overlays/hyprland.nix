final: prev: {
  hyprlandPlugins.hyprsplit = prev.hyprlandPlugins.hyprsplit.overrideAttrs (oldAttrs: rec {
    version = "0.54.1";
    src = final.pkgs.fetchFromGitHub {
      owner = "shezdy";
      repo = "hyprsplit";
      tag = "v${version}";
      hash = "sha256-IksjbT24cgWl2h6ZV4bPxoORmHCQ7h/M/OLQ4epReAE=";
    };
  });
}
