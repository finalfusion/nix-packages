{ stdenv
, lib
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

# Native build inputs
, installShellFiles ? null # Available in 19.09 and later.
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
    rev = "0.9.0";
    sha256 = "0ffwh3rbjn9cl8fdg9jaq035lkphbrhpxjm2dqvx46kzjn9550qm";
  };
  cargo_nix = callPackage ./finalfusion-utils.nix {
    rootFeatures = [ "default" ]
                   ++ lib.optional withOpenblas "openblas"
                   ++ lib.optional withMkl "intel-mkl" ;
  };
in cargo_nix.workspaceMembers.finalfusion-utils.build.override {
  crateOverrides = defaultCrateOverrides // {
    finalfusion-utils = attr: rec {
      inherit src;

      pname = "finalfusion-utils";
      name = "${pname}-${attr.version}";

      nativeBuildInputs = lib.optional (!isNull installShellFiles) installShellFiles;

      buildInputs = lib.optionals withOpenblas [ gfortran.cc.lib openblasCompat ]
        ++ stdenv.lib.optional stdenv.isDarwin darwin.Security;

      postBuild = ''
        for shell in bash fish zsh; do
          target/bin/finalfusion-utils completions $shell > completions.$shell
        done
      '';

      postInstall = ''
        mv $out/bin/finalfusion-utils $out/bin/finalfusion
        rm $out/bin/*.d

        # We do not care for finalfusion-utils as a library crate. Removing
        # the library reduces the number of dependencies.
        rm -rf $out/lib
      '' + lib.optionalString (!isNull installShellFiles) ''
        # Install shell completions
        installShellCompletion completions.{bash,fish,zsh}
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
}
