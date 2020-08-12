{ pkgs ? import (import ./nix/sources.nix).nixpkgs {} }:

let
  rustNightly = pkgs.callPackage ./nix/rustNightly.nix {};
in {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  finalfrontier = builtins.trace
    "finalfrontier is in nixpkgs since 2020-07-26. This attribute will become an alias nixpkgs 20.09 is released."
    (pkgs.callPackage ./pkgs/finalfrontier {});

  finalfusion-utils = builtins.trace
    "finalfusion-utils is in nixpkgs since 2020-08-05. This attribute will be an alias when nixpkgs 20.09 is released."
    (pkgs.callPackage ./pkgs/finalfusion-utils {
      withOpenblas = true;
    });

  python3Packages = pkgs.recurseIntoAttrs(
    pkgs.python3Packages.callPackage ./pkgs/python-modules {}
  );
}
