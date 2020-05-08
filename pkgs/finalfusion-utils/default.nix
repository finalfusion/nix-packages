{ stdenv
, lib
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, installShellFiles
, perl
, pkgconfig

# Build inputs
, darwin
, mkl
, openblasCompat
, gfortran

# Build finalfusion-utils with MKL or OpenBLAS support. MKL support
# requires an MKL derivation that exposes pkg-config files.
, withMkl ? false
, withOpenblas ? false
}:

assert !(withMkl && withOpenblas);

let
  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-utils";
    rev = "0.11.0";
    sha256 = "1xplrd0ikv0a9apy87sbkfzmnsg0giy31gnkbm74fxzc8p82cs47";
  };
  cargo_nix = callPackage ./Crate.nix {
    defaultCrateOverrides = crateOverrides;
    rootFeatures = [ "default" ]
                   ++ lib.optional withOpenblas "openblas"
                   ++ lib.optional withMkl "intel-mkl" ;
  };
  crateOverrides = defaultCrateOverrides // {
    finalfusion-utils = attr: rec {
      inherit src;

      pname = "finalfusion-utils";
      name = "${pname}-${attr.version}";

      nativeBuildInputs = [ installShellFiles ];

      buildInputs = lib.optionals withOpenblas [ gfortran.cc.lib openblasCompat ]
        ++ stdenv.lib.optional stdenv.isDarwin darwin.Security;

      postBuild = ''
        for shell in bash fish zsh; do
          target/bin/finalfusion completions $shell > finalfusion-utils.$shell
        done
      '';

      postInstall = ''
        # Install shell completions
        installShellCompletion finalfusion-utils.{bash,fish,zsh}
      '';

      meta = with stdenv.lib; {
        description = "Utilities for finalfusion word embeddings";
        license = licenses.free;
        platforms = platforms.all;
      };
    };

    intel-mkl-src = attr: rec {
      nativeBuildInputs = [ pkgconfig ];

      buildInputs = [ mkl ];
    };

    openblas-src = attr: rec {
      nativeBuildInputs = [ perl ];

      preConfigure = ''
        export CARGO_FEATURE_SYSTEM=1;
      '';
    };
  };
in cargo_nix.workspaceMembers.finalfusion-utils.build
