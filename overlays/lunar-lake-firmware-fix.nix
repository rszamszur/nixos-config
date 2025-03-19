final: prev: {
  linux-firmware = prev.linux-firmware.overrideAttrs (old: {
    postInstall = ''
      cp ${../firmware/ibt-0190-0291-iml.sfi} $out/lib/firmware/intel/ibt-0190-0291-iml.sfi
      cp ${../firmware/ibt-0190-0291-usb.sfi} $out/lib/firmware/intel/ibt-0190-0291-usb.sfi
    '';
  });
}
