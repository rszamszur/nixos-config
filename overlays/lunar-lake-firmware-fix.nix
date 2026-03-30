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
    version = "676d1ee761ef52aae76c19487957792edd96bd2e";
    src = fetchTarball {
      url = "https://github.com/alsa-project/alsa-ucm-conf/archive/${version}.tar.gz";
      sha256 = "sha256:0dbayripzbnq5mmsy3m9j4k6hrwan74qxlz0w0qik9g59cg6mh2r";
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
    version = "26.1.5";
    src = final.fetchFromGitHub {
      owner = "intel";
      repo = "media-driver";
      rev = "intel-media-${version}";
      hash = "sha256-/11u4dp98ymIpfn0JXzNFZZ0iVYmt6tyikCms4+7r2o=";
    };
  });
}
