{ lib }:

let
  callLibs = file: import file { inherit lib; };
in
{
  trivial = callLibs ./trivial.nix;
}
