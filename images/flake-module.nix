{ self, lib, withSystem, ... }:

{
  flake = {
    packages.aarch64-linux = withSystem "x86_64-linux" (ctx@{ pkgs, ... }: {
      rpi-fanshim = import ./rpi-fanshim {
        inherit pkgs;
        RPiGPIO = self.packages.aarch64-linux.RPiGPIO;
        fanshim = self.packages.aarch64-linux.fanshim;
        apa102 = self.packages.aarch64-linux.apa102;
      };
    });
  };
}
  