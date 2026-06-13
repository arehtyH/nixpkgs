{
  cmake,
  fetchFromGitHub,
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "highwayhash";
  version = "0-unstable-2024-04-17";

  src = fetchFromGitHub {
    owner = "google";
    repo = "highwayhash";
    rev = "f8381f3331d9c56a9792f9b4a35f61c41108c39e";
    hash = "sha256-h1zZChOPTHp1mYIt5UOUKyze8hS4kOTZ1GUtb2yPKIQ=";
  };

  nativeBuildInputs = [ cmake ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp libhighwayhash.a $out/lib

    mkdir -p $out/include
    cp ../highwayhash/{c_bindings.h,highwayhash.h} $out/include

    runHook postInstall
  '';

  meta = {
    description = "Fast strong hash functions";
    homepage = "https://github.com/google/highwayhash";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
