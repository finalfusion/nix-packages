{ buildPythonPackage
, fetchFromGitHub
, stdenv

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
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "finalfusion";
    repo = "finalfusion-python";
    rev = version;
    sha256 = "1g3d9916sywbfl8xzj200jsij4d62jzjd5rkajslrwb0mpwmw4nl";
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

  checkPhase = ''
    pytest

    patchShebangs tests/integration
    export PATH=$PATH:$out/bin
    tests/integration/all.sh
  '';

  meta = with stdenv.lib; {
    description = "Python module for the finalfusion embedding format";
    # Until Blue Oak Model License is added, close approximation.
    license = licenses.asl20;
    maintainers = with maintainers; [ danieldk ];
    platforms = platforms.all;
  };
}
