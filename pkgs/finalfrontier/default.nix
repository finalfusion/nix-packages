{ lib
, stdenv
, stdenvNoCC
, callPackage
, defaultCrateOverrides
, fetchFromGitHub

  # Native build inputs
, gnumake
, pandoc

  # Build inputs
, darwin
}:

let
  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfrontier";
    rev = "0.6.1";
    sha256 = "1yswamvn58jqskg8vj72lwy22y0b30n83wxm5jb080147zvr0sf8";
  };
  cargo_nix = callPackage ./finalfrontier.nix {};
in
cargo_nix.workspaceMembers.finalfrontier-utils.build.override {
  crateOverrides = defaultCrateOverrides // {
    hogwild = attr: { src = "${src}/hogwild"; };

    finalfrontier = attr: { src = "${src}/finalfrontier"; };

    finalfrontier-utils = attr: rec {
      inherit src;

      pname = "finalfrontier";
      name = "${pname}-${attr.version}";

      sourceRoot = "source/finalfrontier-utils";

      nativeBuildInputs = [ gnumake pandoc ];

      buildInputs = stdenv.lib.optional stdenv.isDarwin darwin.Security;

      postBuild = ''
        # Builder only sets proper write permissions on sourceRoot.
        ( cd ../man ; chmod u+w . ; make )
      '';

      postInstall = ''
        rm $out/bin/*.d

        # Remove finalfrontier_utils library.
        rm -rf $out/lib

        # Install man pages.
        mkdir -p "$out/share/man/man1"
        cp ../man/*.1 "$out/share/man/man1/"
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
