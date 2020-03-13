{ stdenv
, callPackage
, defaultCrateOverrides
, fetchFromGitHub
, makeRustPlatform

  # Native build inputs
, maturin
, rustNightly

  # Build inputs
, darwin
, python

  # Propagated build inputs
, numpy

  # Check inputs
, pytest
}:

(rustNightly "2019-07-30").buildRustPackage rec {
  pname = "finalfusion";
  version = "0.6.1";
  name = "${python.libPrefix}-${pname}-${version}";

  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-python";
    rev = version;
    sha256 = "10hzsfn4q40332bzb8imj7ydxfls8z1d6vgafmhalcwq5i0vify1";
  };

  cargoSha256 = "1cmw9bjwnscrhp528w8fxka7w8bsc19asdvj921blrrzgadq7p38";

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
