{ config, lib, pkgs, ... }:

let
  cfg = config.my.cache;
  buildCacheUploadHook = key: pkgs.writeShellApplication {
    name = "nixgard-upload";
    runtimeInputs = [ pkgs.nix ];
    runtimeEnv = {
      IFS = " ";
      SIGN_KEY_PATH = key;
    };
    bashOptions = [
      "errexit"
      "nounset"
      "noglob"
    ];
    excludeShellChecks = [
      "SC2086"
    ];
    text = ''
      if [[ -n "$OUT_PATHS" ]]; then
        echo "Signing paths" $OUT_PATHS
        nix store sign -k "$SIGN_KEY_PATH" $OUT_PATHS
        echo "Uploading to cache: $OUT_PATHS"
        exec nix copy --to 'http://nixgard.szamszur.cloud' $OUT_PATHS -vvv
      fi
    '';
  };
in
{
  options.my.cache = {
    enable = lib.mkEnableOption "Enable cache module.";
    extraSubstituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of extra substituters.";
    };
    extraTrustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of extra trusted public keys.";
    };
    binaryCacheKey = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = lib.mdDoc ''
        The full path to a file which contains the binary cache private key.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        substituters = [
          "http://nixgard.szamszur.cloud"
        ] ++ cfg.extraSubstituters;
        trusted-public-keys = [
          "nixgard.szamszur.cloud:HaXsNyMojj3pVViZDoH8n9uJgqGcoZ6V1yYIFSigOxY="
        ] ++ cfg.extraTrustedPublicKeys;
      };
      extraOptions = lib.mkIf (cfg.binaryCacheKey != null) ''
        post-build-hook = ${buildCacheUploadHook cfg.binaryCacheKey}/bin/nixgard-upload
      '';
    };
  };
}
