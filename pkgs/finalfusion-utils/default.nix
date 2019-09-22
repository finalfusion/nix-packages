{ stdenv
, lib
, callPackage
, fetchFromGitHub
, rustPlatform

  # Native build inputs
, installShellFiles ? null # Available in 19.09 and later.
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

rustPlatform.buildRustPackage rec {
  pname = "finalfusion-utils";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-utils";
    rev = "0.9.0";
    sha256 = "0ffwh3rbjn9cl8fdg9jaq035lkphbrhpxjm2dqvx46kzjn9550qm";
  };

  cargoSha256 = "0r4ns3hyyz3r78xl4h36n23n4nr06xwvlz3qw00bkd2qmcqfxq72";

  cargoBuildFlags = lib.optional withOpenblas "--features openblas"
    ++ lib.optional withMkl "intel-mkl";

  nativeBuildInputs = lib.optional (!isNull installShellFiles) installShellFiles;

  buildInputs = lib.optionals withOpenblas [ gfortran.cc.lib openblasCompat ]
    ++ stdenv.lib.optional stdenv.isDarwin darwin.Security
    ++ lib.optional withMkl mkl;

  postBuild = ''
    for shell in bash fish zsh; do
      target/release/finalfusion completions $shell > completions.$shell
    done
  '';

  postInstall = lib.optionalString (!isNull installShellFiles) ''
    # Install shell completions
    installShellCompletion completions.{bash,fish,zsh}
  '';

  meta = with stdenv.lib; {
    description = "Utilities for finalfusion word embeddings";
    license = licenses.free;
    platforms = platforms.all;
  };
}
