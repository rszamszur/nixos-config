{ self, lib, ... }:

let
  buildPyShells =
    { shell
    , name
    , pkgs
    , pythons ? [
        "python310"
        "python311"
        "python312"
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
  perSystem = { config, self', inputs', pkgs, ... }: {
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
