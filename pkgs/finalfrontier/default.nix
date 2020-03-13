{ lib
, stdenv
, stdenvNoCC
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

  # Native build inputs
, gnumake
, installShellFiles ? null # Available in 19.09 and later.
, pandoc

  # Build inputs
, darwin
, openssl
}:

let
  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfrontier";
    rev = "0.7.0";
    sha256 = "1gqszyl000wlbrmqrv0p8i08gmwy05600ynj96wi5m6fk74fg98a";
  };
  cargo_nix = callPackage ./Cargo.nix {};
in
cargo_nix.rootCrate.build.override {
  crateOverrides = defaultCrateOverrides // {
    finalfrontier = attr: rec {
      inherit src;

      pname = "finalfrontier";
      name = "${pname}-${attr.version}";

      nativeBuildInputs = [ gnumake pandoc ] ++
        lib.optional (!isNull installShellFiles) installShellFiles;

      buildInputs = stdenv.lib.optionals stdenv.isDarwin [
        darwin.Security
        openssl
      ];

      postBuild = ''
        # Builder only sets proper write permissions on sourceRoot.
        ( cd man ; chmod u+w . ; make )

        for shell in bash fish zsh; do
          target/bin/finalfrontier completions $shell > finalfrontier.$shell
        done
      '';

      postInstall = ''
        rm $out/bin/*.d

        # Remove finalfrontier_utils library.
        rm -rf $out/lib

        # Install man pages.
        mkdir -p "$out/share/man/man1"
        cp man/*.1 "$out/share/man/man1/"
      '' + lib.optionalString (!isNull installShellFiles) ''
        # Install shell completions
        installShellCompletion finalfrontier.{bash,fish,zsh}
      '';

      meta = with stdenv.lib; {
        description = "Train word and subword embeddings";
        license = licenses.asl20;
        maintainers = with maintainers; [ danieldk ];
        platforms = platforms.all;
      };
    };
  };
}
