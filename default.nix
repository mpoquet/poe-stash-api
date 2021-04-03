{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz") {}
}:

let self = rec {
  python-shell = pkgs.mkShell rec {
    name = "python-shell";
    buildInputs = [
      pkgs.python3
      pkgs.python3Packages.plotly
      pkgs.python3Packages.pandas
    ] ++ [
      pkgs.python3Packages.pylint
      pkgs.python3Packages.ipython
    ];
  };

  r-shell = pkgs.mkShell rec {
    name = "r-shell";
    buildInputs = [
      pkgs.R
      pkgs.rPackages.tidyverse
      pkgs.rPackages.viridis
      pkgs.rPackages.treemap
    ];
  };
};
in
  self
