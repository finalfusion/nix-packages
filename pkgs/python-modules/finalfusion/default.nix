{ stdenv
, callPackage
, defaultCrateOverrides
, fetchFromGitHub
, python

  # Build inputs
, darwin

  # Propagated build inputs
, numpy

  # Check inputs
, pytest
}:

let
  mozillaOverlay = fetchFromGitHub {
    owner = "mozilla";
    repo = "nixpkgs-mozilla";
    rev = "9f35c4b09fd44a77227e79ff0c1b4b6a69dff533";
    sha256 = "18h0nvh55b5an4gmlgfbvwbyqj91bklf1zymis6lbdh75571qaz0";
  };
  mozilla = callPackage "${mozillaOverlay.out}/package-set.nix" {};
  rustNightly = (mozilla.rustChannelOf { date = "2019-07-19"; channel = "nightly"; }).rust;
  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-python";
    rev = "0.5.0";
    sha256 = "1kkpq8s5bn4gd65gxqxfzi1i4cv8pii0kcr3k0kxybdadqqi5p8a";
  };
  cargo_nix = callPackage ./finalfusion.nix {};
in
cargo_nix.rootCrate.build.override {
  rust = rustNightly;

  crateOverrides = defaultCrateOverrides // {
    finalfusion-python = attr: rec {
      inherit src;

      pname = "finalfusion";
      name = "${python.libPrefix}-${pname}-${attr.version}";

      buildInputs = stdenv.lib.optional stdenv.isDarwin darwin.Security;

      propagatedBuildInputs = [ numpy ];

      installCheckInputs = [ pytest ];

      doInstallCheck = true;

      installPhase = let
        sitePackages = python.sitePackages;
        sharedLibrary = stdenv.hostPlatform.extensions.sharedLibrary;
      in ''
        mkdir -p "$out/${sitePackages}"
        cp target/lib/libfinalfusion-*${sharedLibrary} \
          "$out/${sitePackages}/finalfusion.so"
        export PYTHONPATH="$out/${sitePackages}:$PYTHONPATH"
      '';

      installCheckPhase = ''
        pytest
      '';

      meta = with stdenv.lib; {
        description = "Python module for the finalfusion embedding format";
        license = licenses.asl20;
        maintainers = with maintainers; [ danieldk ];
        platforms = platforms.all;
      };
    };

    pyo3 = attr: {
      buildInputs = [ python ];
    };
  };
}
