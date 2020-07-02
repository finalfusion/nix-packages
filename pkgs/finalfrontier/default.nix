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
        rev = attr.version;
        sha256 = "0lj9vkz6afdhkwqcsklmkghplqw2h1z2pc9wny0mzf7rfa0yf68p";
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
