{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.vscode;

  luahelper = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "luahelper";
    publisher = "yinfei";
    version = "0.2.12";
    sha256 = "sha256:0rdaqdc79g9nbk4dyqjv38ygqp60jf79b1slvcax2sv7nixhlyzc";
  };

  bbenoist-nix = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "nix";
    publisher = "bbenoist";
    version = "1.0.1";
    sha256 = "sha256:0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
  };

  vscode-scss-formatter = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-scss-formatter";
    publisher = "sibiraj-s";
    version = "2.4.1";
    sha256 = "sha256:0mqzl29762qxidqfzh5ndsglaydgs7dbj0kifq10xiak4045dfzr";
  };

  shell-format = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "shell-format";
    publisher = "foxundermoon";
    version = "7.2.2";
    sha256 = "sha256:00wc0y2wpdjs2pbxm6wj9ghhfsvxyzhw1vjvrnn1jfyl4wh3krvi";
  };

  vetur = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vetur";
    publisher = "octref";
    version = "0.35.0";
    sha256 = "sha256:1l1w83yix8ya7si2g3w64mczh0m992c0cp2q0262qp3y0gspnm2j";
  };

  vuetify-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vuetify-vscode";
    publisher = "vuetifyjs";
    version = "0.2.0";
    sha256 = "sha256:0v8qrmdd8diq2bl19y5g4bi7mkwyy9whkn72jg6ha7inx179rv9q";
  };

  markdownlint = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-markdownlint";
    publisher = "davidanson";
    version = "0.47.0";
    sha256 = "sha256:0v50qcfs3jx0m2wqg4qbhw065qzdi57xrzcwnhcpjhg1raiwkl1a";
  };

  vscode-yaml = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "vscode-yaml";
    publisher = "redhat";
    version = "1.14.0";
    sha256 = "sha256:hCRyDA6oZF7hJv0YmbNG3S2XPtNbyxX1j3qL1ixOnF8=";
  };

  bazel-stack-vscode = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "bazel-stack-vscode";
    publisher = "stackbuild";
    version = "1.9.8";
    sha256 = "sha256:7DJ+HQu1qliLuqDH2kkaG7OwD+GQGx61Ue9LE9c3Avk=";
  };

  cue = pkgs.vscode-utils.extensionFromVscodeMarketplace {
    name = "cue";
    publisher = "asdine";
    version = "0.3.2";
    sha256 = "sha256-jMXqhgjRdM3UG/9NtiwWAg61mBW8OYVAKDWgb4hzhA4=";
  };

  vscode = pkgs.vscode-with-extensions.override {
    vscodeExtensions = [
      luahelper
      bbenoist-nix
      vscode-scss-formatter
      shell-format
      vetur
      vuetify-vscode
      markdownlint
      vscode-yaml
      bazel-stack-vscode
      cue
      pkgs.vscode-extensions.ms-kubernetes-tools.vscode-kubernetes-tools
      pkgs.vscode-extensions.hashicorp.terraform
      pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
    ];
  };
in
{

  options.my.vscode.enable = lib.mkEnableOption "Enables vscode with extensions.";

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur =
      { ... }:
      {

        home.packages = [
          vscode
        ];

      };

  };

}
