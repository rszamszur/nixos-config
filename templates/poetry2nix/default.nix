{ lib
, python
, poetry2nix
}:

poetry2nix.mkPoetryApplication {
  inherit python;

  projectDir = ./.;
  pyproject = ./pyproject.toml;
  poetrylock = ./poetry.lock;

  pythonImportsCheck = [ "your_project_module_name" ];


  meta = with lib; {
    homepage = "https://url.for.the.project";
    description = "Description for the project";
    license = licenses.mit;
  };
}
