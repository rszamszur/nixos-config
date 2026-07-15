final: prev: {
  hyprlandPlugins.hyprsplit = prev.hyprlandPlugins.hyprsplit.overrideAttrs (oldAttrs: rec {
    version = "0.54.1";
    src = final.pkgs.fetchFromGitHub {
      owner = "shezdy";
      repo = "hyprsplit";
      tag = "v${version}";
      hash = "sha256-IksjbT24cgWl2h6ZV4bPxoORmHCQ7h/M/OLQ4epReAE=";
    };
  });
  hyprlang = prev.hyprlang.overrideAttrs (oldAttrs: rec {
    version = "0.6.8";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprlang";
      rev = "v${version}";
      hash = "sha256-ZGzcH3gKD9nj8oDLV1+o6ice6kMHZRXkNx24cfyPkRs=";
    };
  });

  hyprutils = prev.hyprutils.overrideAttrs (oldAttrs: rec {
    version = "0.12.0";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprutils";
      tag = "v${version}";
      hash = "sha256-c4YVwO33Mmw+FIV8E0u3atJZagHvGTJ9Jai6RtiB8rE=";
    };
  });

  hyprwayland-scanner = prev.hyprwayland-scanner.overrideAttrs (oldAttrs: rec {
    version = "0.4.5";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprwayland-scanner";
      rev = "v${version}";
      hash = "sha256-FnhBENxihITZldThvbO7883PdXC/2dzW4eiNvtoV5Ao=";
    };
  });

  hyprwire = prev.hyprwire.overrideAttrs (oldAttrs: rec {
    version = "0.3.0";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprwire";
      tag = "v${version}";
      hash = "sha256-PR/KER+yiHabFC/h1Wjb+9fR2Uy0lWM3Qld7jPVaWkk=";
    };
  });

  hyprgraphics = prev.hyprgraphics.overrideAttrs (oldAttrs: rec {
    version = "0.5.0";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprgraphics";
      tag = "v${version}";
      hash = "sha256-MRD+Jr2bY11MzNDfenENhiK6pvN+nHygxdHoHbZ1HtE=";
    };
  });

  hyprland-qtutils = prev.hyprland-qtutils.overrideAttrs (oldAttrs: rec {
    version = "0.1.5";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprland-qtutils";
      tag = "v${version}";
      hash = "sha256-bTYedtQFqqVBAh42scgX7+S3O6XKLnT6FTC6rpmyCCc=";
    };
  });

  hyprcursor = prev.hyprcursor.overrideAttrs (oldAttrs: rec {
    version = "0.1.13";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprcursor";
      tag = "v${version}";
      hash = "sha256-lIqabfBY7z/OANxHoPeIrDJrFyYy9jAM4GQLzZ2feCM=";
    };
  });

  hyprland = prev.hyprland.overrideAttrs (oldAttrs: rec {
    version = "0.54.3";

    src = final.pkgs.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprland";
      fetchSubmodules = true;
      tag = "v${version}";
      hash = "sha256-e+mVjQL3V+xoaH1c3YqAzRq9wwiuEYQTOgZlK0LwfYA=";
    };

    postPatch = ''
      # Fix hardcoded paths to /usr installation
      substituteInPlace src/render/OpenGL.cpp \
        --replace-fail /usr $out

      # Remove extra @PREFIX@ to fix pkg-config paths
      substituteInPlace hyprland.pc.in \
        --replace-fail  "@PREFIX@/" ""
      substituteInPlace example/hyprland.desktop.in \
        --replace-fail  "@PREFIX@/" ""
      substituteInPlace systemd/hyprland-uwsm.desktop \
        --replace-fail "Exec=uwsm " "Exec=${final.lib.getExe final.uwsm} " \
        --replace-fail "TryExec=uwsm" "TryExec=${final.lib.getExe final.uwsm}"
    '';

    # variables used by CMake, and shown in `hyprctl version`
    env = {
      GIT_BRANCH = "v0.54.3-b";
      # The amount of commits altogether. Not really worth getting that info from
      # GitHub's API, so we set a dummy value.
      GIT_COMMITS = "-1";
      GIT_COMMIT_DATE = "2026-03-27";
      GIT_DIRTY = "clean";
      GIT_COMMIT_HASH = "521ece463c4a9d3d128670688a34756805a4328f";
      GIT_COMMIT_MESSAGE = "version: bump to 0.54.3";
      GIT_TAG = "v0.54.3";
    };
  });
}
