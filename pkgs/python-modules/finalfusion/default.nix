{ stdenv
, callPackage
, defaultCrateOverrides
, fetchFromGitHub
, makeRustPlatform

  # Native build inputs
, maturin

  # Build inputs
, darwin
, python

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
  rustNightly = (mozilla.rustChannelOf { date = "2019-07-30"; channel = "nightly"; }).rust;
  rustPlatform = makeRustPlatform { cargo = rustNightly; rustc = rustNightly; };
in rustPlatform.buildRustPackage rec {
  pname = "finalfusion";
  version = "0.6.0";
  name = "${python.libPrefix}-${pname}-${version}";

  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-python";
    rev = version;
    sha256 = "1wv53rycj4v5q73iai9zz7d9akqgdgdhfxxqm887dw6kxvjwcq09";
  };

  cargoSha256 = "0ydfiw001nr9l4b43jwi0zwd2q58v85c4xhi4jr59n9d1sx7j7w9";

  nativeBuildInputs = [ maturin python.pkgs.pip ];

  buildInputs = [ python ] ++ stdenv.lib.optional stdenv.isDarwin darwin.Security;

  propagatedBuildInputs = [ numpy ];

  installCheckInputs = [ pytest ];

  doCheck = false;

  doInstallCheck = true;

  buildPhase = ''
    runHook preBuild

    maturin build --release --manylinux off

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${python.pythonForBuild.pkgs.bootstrapped-pip}/bin/pip install \
      target/wheels/*.whl --no-index --prefix=$out --no-cache --build tmpbuild

    runHook postInstall
  '';

  installCheckPhase = let
    sitePackages = python.sitePackages;
  in ''
    PYTHONPATH="$out/${sitePackages}:$PYTHONPATH" pytest
  '';

  meta = with stdenv.lib; {
    description = "Python module for the finalfusion embedding format";
    license = licenses.asl20;
    maintainers = with maintainers; [ danieldk ];
    platforms = platforms.all;
  };
}
