{ pkgs ? import (import ./nix/sources.nix).nixpkgs {} }:

let
  mkl = pkgs.callPackage ./pkgs/mkl {};
  rustNightly = pkgs.callPackage ./nix/rustNightly.nix {};
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  finalfrontier = pkgs.callPackage ./pkgs/finalfrontier {};

  finalfusion = pkgs.callPackage ./pkgs/finalfusion-utils {
    inherit mkl;
    withOpenblas = true;
  };

  finalfusion-utils =
    builtins.trace "finalfusion-utils is renamed to finalfusion" finalfusion;

  finalfusionWithMkl = pkgs.callPackage ./pkgs/finalfusion-utils {
    inherit mkl;
    withMkl = true;
  };

  python3Packages = pkgs.recurseIntoAttrs(
    pkgs.python3Packages.callPackage ./pkgs/python-modules {
      inherit rustNightly;
    }
  );
}
