{ self, lib, ... }:

let
  buildPyShells =
    { shell
    , name
    , pkgs
    , pythons ? [
        "python311"
        "python312Full"
        "python313"
        "python314"
      ]
    ,
    }:
    lib.listToAttrs (map
      (python: {
        name = "${python}-${name}";
        value = import shell { inherit pkgs python; };
      })
      pythons);
in
{
  perSystem = { config, pkgs, ... }: {
    devShells = {
      default = import ./default.nix { inherit pkgs; };
      nodejs = import ./js.nix { inherit pkgs; };
      ruby = import ./ruby.nix { inherit pkgs; };
    } // buildPyShells {
      inherit pkgs;
      shell = ./py3-pip.nix;
      name = "pip";
    } // buildPyShells {
      inherit pkgs;
      shell = ./py3-poetry.nix;
      name = "poetry";
    };
  };
}
