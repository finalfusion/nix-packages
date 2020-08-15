{ buildPythonPackage
, fetchFromGitHub
, lib

  # Native build inputs
, cython

  # Propagated build inputs
, numpy
, toml

  # Check inputs
, pytest
}:

buildPythonPackage rec {
  pname = "finalfusion";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-python";
    rev = version;
    sha256 = "0pwzflamxqvpl1wcz0zbhhd6aa4xn18rmza6rggaic3ckidhyrh4";
  };

  nativeBuildInputs = [
    cython
  ];

  propagatedBuildInputs = [
    numpy
    toml
  ];

  checkInputs = [
    pytest
  ];

  postPatch = ''
    patchShebangs tests/integration
  '';

  checkPhase = ''
    pytest

    export PATH=$PATH:$out/bin
    tests/integration/all.sh
  '';

  meta = with lib; {
    description = "Python module for the finalfusion embedding format";
    # Until Blue Oak Model License is added, close approximation.
    license = licenses.asl20;
    maintainers = with maintainers; [ danieldk ];
    platforms = platforms.all;
  };
}
