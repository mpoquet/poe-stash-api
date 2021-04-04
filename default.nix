{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/20.09.tar.gz") {}
}:

let self = rec {
  pythonPackages = pkgs.python3Packages;

  poe-stash-api = pythonPackages.buildPythonPackage {
    name = "poe-stash-api-0.1.0";
    propagatedBuildInputs = with pythonPackages; [
      requests
      pandas
    ];
    src = pkgs.lib.sourceByRegex ./. [
      "^setup\.py"
      "^poe_stash_api"
      "^poe_stash_api/.*\.py"
    ];
  };

  test-py-shell = pkgs.mkShell rec {
    name = "test-py-shell";
    buildInputs = with pythonPackages; [
      poe-stash-api
      pylint
      ipython
    ];
  };

  r-shell = pkgs.mkShell rec {
    name = "r-shell";
    buildInputs = [
      pkgs.R
      pkgs.rPackages.tidyverse
      pkgs.rPackages.viridis
      pkgs.rPackages.treemap
      pkgs.rPackages.tidytext
    ];
  };
};
in
  self
