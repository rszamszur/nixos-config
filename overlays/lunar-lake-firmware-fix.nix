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
    version = "1b69ade9b6d7ee37a87c08b12d7955d0b68fa69d";
    src = fetchTarball {
      url = "https://github.com/alsa-project/alsa-ucm-conf/archive/${version}.tar.gz";
      sha256 = "sha256:0x8774j6bv4a68syiznxlwp4zydx6l14akg3kl7bd1nhzgbliz7c";
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
    version = "25.2.6";
    src = final.fetchFromGitHub {
      owner = "intel";
      repo = "media-driver";
      rev = "intel-media-${version}";
      hash = "sha256-+gcecl04LSFTb9mn+2oJ07/z8aGYezP4AdeITlTS5OY=";
    };
  });
}
