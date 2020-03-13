{ callPackage, rustNightly }:

{
  finalfusion = callPackage ./finalfusion {
    inherit rustNightly;
  };
}
