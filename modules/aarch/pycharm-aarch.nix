{ lib
, stdenv
, pname ? "pycharm-community"
, version ? "2022.3"
, product ? "PyCharm CE"
, productShort ? "PyCharm"
, wmClass ? "jetbrains-pycharm-ce"
, fetchurl
, makeDesktopItem
, patchelf
, makeWrapper
, python3
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
    url = "https://download.jetbrains.com/python/pycharm-community-${version}-aarch64.tar.gz";
    sha256 = "sha256-tpArGiv4SJ6RH0Cjo/v/RDWjOpnxxUobmlRHYSVA1m8=";
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    desktopName = product;
    genericName = "PyCharm Community Edition";
    categories = [ "Development" ];
    icon = pname;
    startupWMClass = wmClass;
  };

  extraLdPath = [ ];
  extraWrapperArgs = [ ];

  nativeBuildInputs = [ makeWrapper patchelf unzip ];
  buildInputs = with python3.pkgs; [ python3 setuptools ];

  preInstall = ''
    echo "compiling cython debug speedups"
    if [[ -d plugins/python-ce ]]; then
      ${python3.interpreter} plugins/python-ce/helpers/pydev/setup_cython.py build_ext --inplace
    else
      ${python3.interpreter} plugins/python/helpers/pydev/setup_cython.py build_ext --inplace
    fi
  '';

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
