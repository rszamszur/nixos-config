{ lib
, stdenv
, pname ? "idea-community"
, version ? "2022.3"
, product ? "IntelliJ IDEA CE"
, productShort ? "IDEA"
, wmClass ? "jetbrains-idea-ce"
, fetchurl
, makeDesktopItem
, patchelf
, makeWrapper
, maven
, zlib
, jdk
, coreutils
, gnugrep
, which
, git
, unzip
, libsecret
, libnotify
, e2fsprogs
}:

let
  loName = lib.toLower productShort;
  hiName = lib.toUpper productShort;
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIC-${version}-aarch64.tar.gz";
    sha256 = "sha256-x6edR6ZfY4hK5X+MkkZ+C00bMICEqXJCiee0IXOytTI=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    desktopName = product;
    genericName = "Integrated Development Environment (IDE) by Jetbrains, community edition";
    categories = [ "Development" ];
    icon = pname;
    startupWMClass = wmClass;
  };

  extraLdPath = [ zlib ];
  extraWrapperArgs = [
    ''--set M2_HOME "${maven}/maven"''
    ''--set M2 "${maven}/maven/bin"''
  ];

  nativeBuildInputs = [ makeWrapper patchelf unzip ];

  postPatch = ''
    get_file_size() {
      local fname="$1"
      echo $(ls -l $fname | cut -d ' ' -f5)
    }
      
    munge_size_hack() {
      local fname="$1"
      local size="$2"
      strip $fname
      truncate --size=$size $fname
    }
      
    interpreter=$(echo ${stdenv.cc.libc}/lib/ld-linux*.so.2)
    target_size=$(get_file_size bin/fsnotifier)
    patchelf --set-interpreter "$interpreter" bin/fsnotifier
    munge_size_hack bin/fsnotifier $target_size
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,$pname,share/pixmaps,libexec/${pname}}
    cp -a . $out/$pname
    ln -s $out/$pname/bin/${loName}.png $out/share/pixmaps/${pname}.png
    mv bin/fsnotifier* $out/libexec/${pname}/.
    
    jdk=${jdk.home}
    item=${desktopItem}
    
    makeWrapper "$out/$pname/bin/${loName}.sh" "$out/bin/${pname}" \
      --prefix PATH : "$out/libexec/${pname}:${lib.makeBinPath [ jdk coreutils gnugrep which git ]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath ([
        # Some internals want libstdc++.so.6
        stdenv.cc.cc.lib libsecret e2fsprogs
        libnotify
      ] ++ extraLdPath)}" \
      ${lib.concatStringsSep " " extraWrapperArgs} \
      --set-default JDK_HOME "$jdk" \
      --set-default ANDROID_JAVA_HOME "$jdk" \
      --set-default JAVA_HOME "$jdk" \
      --set-default JETBRAINSCLIENT_JDK "$jdk" \
      --set ${hiName}_JDK "$jdk" \
    
    ln -s "$item/share/applications" $out/share
    
    runHook postInstall
  '';

}
