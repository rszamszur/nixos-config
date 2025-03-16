{ lib }:

let
  inherit (lib.attrsets) filterAttrs;
  inherit (builtins) hasAttr;
in
{
  inheritAllExcept = attrset: exclude: filterAttrs (n: v: ! builtins.elem n exclude) attrset;
  # https://github.com/NixOS/nixpkgs/blob/5b7441fb4b0c4aeed10b1a583299642c2ad7fd76/lib/modules.nix#L1290
  # Removed options marked with lib.mkRemovedOptionModule will have visible = false name-value pair in the option attrset.
  filterRemovedOptions = options: filterAttrs (n: v: !(hasAttr "visible" v && v.visible == false)) options;
}
