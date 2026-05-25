final: prev: {
  hyprlandPlugins.hyprsplit = prev.hyprlandPlugins.hyprsplit.overrideAttrs (oldAttrs: rec {
    version = "0.54.4";
    src = final.pkgs.fetchFromGitHub {
      owner = "shezdy";
      repo = "hyprsplit";
      #tag = "v${version}";
      rev = "0fc01e7930625ecb3e069f5dc8e1d61eab929f3b";
      hash = "sha256-XpwuFhwnfwPbzImZeUWWns///UEpoKNkpl1hN90C3Ag=";
    };
  });
}
