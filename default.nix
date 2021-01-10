{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz") {}
}:

pkgs.mkShell rec {
  name = "pyenv";
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.plotly
    pkgs.python3Packages.pandas
  ] ++ [
    pkgs.python3Packages.pylint
    pkgs.python3Packages.ipython
  ];
}
