{ lib
, stdenv
, stdenvNoCC
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

  # Native build inputs
, gnumake
, installShellFiles
, pandoc

  # Build inputs
, darwin
, libiconv
, openssl
}:

let
  cargo_nix = callPackage ./Cargo.nix {
    defaultCrateOverrides = crateOverrides;
  };
  crateOverrides = defaultCrateOverrides // {
    finalfrontier = attr: rec {
      src = fetchFromGitHub {
        owner = "finalfusion";
        repo = "finalfrontier";
        rev = "0.8.0";
        sha256 = "1bc131dczwrslriadm4103qwfxpvhp2v27cq5zqbqy6sb6k2amq0";
      };

      pname = "finalfrontier";
      name = "${pname}-${attr.version}";

      nativeBuildInputs = [ gnumake installShellFiles pandoc ];

      buildInputs = stdenv.lib.optionals stdenv.isDarwin [
        darwin.Security
        libiconv
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
        # Install man pages.
        mkdir -p "$out/share/man/man1"
        cp man/*.1 "$out/share/man/man1/"

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
in cargo_nix.rootCrate.build
