{ config, lib, pkgs, ... }:

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

  vscode = pkgs.vscode-with-extensions.override {
    vscodeExtensions = [
      luahelper
      bbenoist-nix
      vscode-scss-formatter
      shell-format
      vetur
      vuetify-vscode
    ];
  };
in
{

  options.my.vscode.enable = lib.mkEnableOption "Enables vscode with extensions.";

  config = lib.mkIf cfg.enable {

    home-manager.users.rszamszur = { ... }: {

      home.packages = [
        vscode
      ];

    };

  };

}
