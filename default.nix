{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/22.05.tar.gz";
    sha256 = "0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
  }) {}
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
