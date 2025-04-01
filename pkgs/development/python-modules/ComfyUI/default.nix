{ lib
, buildPythonPackage
, fetchFromGitHub
, pkgs
, gpuBackend ? "cuda"
  # , setuptools

}:

buildPythonPackage rec {
  pname = "ComfyUI";
  version = "0.3.14";
  # pyproject = true;

  src = fetchFromGitHub {
    owner = "comfyanonymous";
    repo = "ComfyUI";
    rev = "v${version}";
    hash = "sha256-Jj4VFBqwa1ZaOprrF2ie4u9/BKJJ41rvYbNjOMHc5jM=";
  };

  # List of dependencies required by your Python package
  dependencies = [
    (
      if gpuBackend == "cuda"
      then pkgs.python312Packages.torchWithCuda
      else if gpuBackend == "rocm"
      then pkgs.python312Packages.torchWithRocm
      else pkgs.python312Packages.torch
    )
    pkgs.python312Packages.torchsde
    pkgs.python312Packages.torchvision
    pkgs.python312Packages.torchaudio
    pkgs.python312Packages.numpy
    pkgs.python312Packages.einops
    pkgs.python312Packages.transformers
    pkgs.python312Packages.tokenizers
    pkgs.python312Packages.sentencepiece
    pkgs.python312Packages.safetensors
    pkgs.python312Packages.aiohttp
    pkgs.python312Packages.pyyaml
    pkgs.python312Packages.pillow
    pkgs.python312Packages.scipy
    pkgs.python312Packages.tqdm
    pkgs.python312Packages.psutil

    pkgs.python312Packages.kornia
    # pkgs.python312Packages.spandrel
    pkgs.python312Packages.soundfile
  ];

  # If you have native dependencies that need to be compiled against,
  # you would list them in buildInputs.
  # buildInputs = [
  #   pkgs.python312Packages.setuptools
  #   pkgs.python312Packages.pip
  #   pkgs.python312Packages.wheel
  # ];
  build-system = [
    pkgs.python312Packages.setuptools
  ];

  preBuild = ''
    cat > setup.py << EOF
    from setuptools import setup, find_packages

    with open('requirements.txt') as f:
        install_requires = f.read().splitlines()

    setup(
      name='comfyui',
      packages=['comfyui', 'app', 'web', 'comfy', 'input', 'models', 'output', 'notebooks', 'api_server', 'comfy_extras', 'custom_nodes', 'comfy_execution', 'script_examples'],
      #packages=find_packages(exclude=['tests*', 'notebooks*']),
      package_dir={
          'comfyui': '.',
      },
      include_package_data = True,
      version='0.3.14',
      #author='...',
      #description='...',
      install_requires=[line.strip() for line in open('requirements.txt') if not line.startswith('#')],
      # scripts=[
      #   'main.py',
      # ],

      entry_points={
        'console_scripts': [
            'comfyui=comfyui.main:__main__',
            # Add other console scripts here
        ]
    },
    )
    EOF
  '';

  # preBuild = ''
  #   echo "[tool.setuptools]" >> pyproject.toml
  #   echo "packages = []" >> pyproject.toml
  #   echo "py-modules = []" >> pyproject.toml
  # '';

  doCheck = false;
  catchConflicts = false;
  # nativeBuildInputs = [
  #   pkgs.cmake
  # ];

  meta = {
    description = "The most powerful and modular diffusion model GUI, api and backend with a graph/nodes interface.";
    homepage = https://github.com/comfyanonymous/ComfyUI;
    license = pkgs.lib.licenses.gpl3;
  };
}
