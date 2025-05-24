final: prev: {
  linux-firmware = prev.linux-firmware.overrideAttrs (old: {
    postInstall = ''
      cp ${../firmware/ibt-0190-0291-iml.sfi} $out/lib/firmware/intel/ibt-0190-0291-iml.sfi
      cp ${../firmware/ibt-0190-0291-usb.sfi} $out/lib/firmware/intel/ibt-0190-0291-usb.sfi
      # ls -lah $out/lib/firmware/intel
      # mkdir $out/lib/firmware/intel/sof-ipc4-tplg
      # cp ${../firmware/sof-lnl-cs42l43-l0-cs35l56-l23-2ch.tplg} $out/lib/firmware/intel/sof-ipc4-tplg/sof-lnl-cs42l43-l0-cs35l56-l23-2ch.tplg
    '';
  });
  # alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (finalAttrs: previousAttrs: {
  #   version = "1.2.14";
  #   src = final.fetchurl {
  #     url = "mirror://alsa/lib/alsa-ucm-conf-${finalAttrs.version}.tar.bz2";
  #     hash = "sha256-MumAn1ktkrl4qhAy41KTwzuNDx7Edfk3Aiw+6aMGnCE=";
  #   };
  # });
  # sof-firmware = prev.sof-firmware.overrideAttrs (finalAttrs: previousAttrs: {
  #   version = "2025.01.1";
  #   src = final.fetchurl {
  #     url = "https://github.com/thesofproject/sof-bin/releases/download/v${finalAttrs.version}/sof-bin-${finalAttrs.version}.tar.gz";
  #     sha256 = "sha256-o2IQ2cJF6BsNlnTWsn0f1BIpaM+SWu/FW0htNlD4gyM=";
  #   };
  # });
  # alsa-lib = prev.alsa-lib.overrideAttrs (finalAttrs: previousAttrs: {
  #   version = "1.2.13";
  #   src = final.fetchurl {
  #     url = "mirror://alsa/lib/alsa-lib-${finalAttrs.version}.tar.bz2";
  #     hash = "sha256-jE/zdVPL6JYY4Yfkx3n3GpuyqLJ7kfh+1AmHzJIz2PY=";
  #   };
  # });
  # alsa-utils = prev.alsa-utils.overrideAttrs (finalAttrs: previousAttrs: {
  #   version = "1.2.13";
  #   src = final.fetchurl {
  #     url = "mirror://alsa/utils/alsa-utils-${finalAttrs.version}.tar.bz2";
  #     hash = "sha256-FwKmsc35uj6ZbsvB3c+RceaAj1lh1QPQ8n6A7hYvHao=";
  #   };
  # });
}
