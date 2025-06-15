final: prev: {
  linux-firmware = prev.linux-firmware.overrideAttrs (old: {
    postInstall = ''
      cp ${../firmware/ibt-0190-0291-iml.sfi} $out/lib/firmware/intel/ibt-0190-0291-iml.sfi
      cp ${../firmware/ibt-0190-0291-usb.sfi} $out/lib/firmware/intel/ibt-0190-0291-usb.sfi
    '';
  });
  # Solution thanks to:
  # https://www.reddit.com/r/NixOS/comments/1khgybw/asus_zenbook_s14_speaker_not_working_ux5406sa
  my-alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (oldAttrs: rec {
    version = "421e37bae75efc1fc134fbc84bc301f041aaff3b";
    src = fetchTarball {
      url = "https://github.com/alsa-project/alsa-ucm-conf/archive/${version}.tar.gz";
      sha256 = "sha256:08rsv6wn32d9zrw1gl2jp7rqzj8m6bdkn0xc7drzf9gfbf6fvmpb";
    };
    # Override the installPhase to avoid problematic substitutions
    installPhase = ''
      mkdir -p $out/share/alsa
      cp -r ucm2 $out/share/alsa/
    '';
    # Disable postInstall to avoid substitutions
    postInstall = "";
  });
  my-intel-media-driver = prev.intel-media-driver.overrideAttrs (oldAttrs: rec {
    version = "25.2.4";
    src = final.fetchFromGitHub {
      owner = "intel";
      repo = "media-driver";
      rev = "intel-media-${version}";
      hash = "sha256-tfI7jeNWN7v35wrdEY2fczaaRBRwvmL3K1gwYlU/V80=";
    };
  });
}
