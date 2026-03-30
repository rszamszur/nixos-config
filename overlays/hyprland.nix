final: prev: {
  hyprlandPlugins.hyprsplit = prev.hyprlandPlugins.hyprsplit.overrideAttrs (oldAttrs: rec {
    version = "0.54.3";
    src = final.pkgs.fetchFromGitHub {
      owner = "shezdy";
      repo = "hyprsplit";
      tag = "v${version}";
      hash = "sha256-iNVMR/Kkory/Km2w7cZGHYABtL4aATFU2pydQOS9xiM=";
    };
  });
}
