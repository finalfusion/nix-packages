{ callPackage }:

{
  finalfusion = builtins.trace
    "python3Packages.finalfusion is in nixpkgs since 2020-08-17. This attribute will be an alias when nixpkgs 20.09 is released."
    callPackage ./finalfusion {};
}
