{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  finalfusion-utils = pkgs.callPackage ./pkgs/finalfusion-utils {
    withOpenblas = true;
  };
}
