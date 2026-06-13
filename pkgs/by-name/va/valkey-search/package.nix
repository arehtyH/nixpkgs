{
  abseil-cpp,
  callPackage,
  cmake,
  fetchFromGitHub,
  gbenchmark,
  grpc,
  gtest,
  icu,
  lib,
  openssl,
  protobuf,
  stdenv,
}:
let
  highwayhash = callPackage ./highwayhash.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "valkey-search";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "valkey-io";
    repo = "valkey-search";
    tag = finalAttrs.version;
    hash = "sha256-GBrntu22N0zr2q00Yxkl9pVXpTve1J7g6/Z+mxo6uvA=";
  };

  patches = [
    ./fix-submodules.patch
    ./dynamic-libs.patch
  ];

  cmakeFlags = [
    "-DCMAKE_PREFIX_PATH=${abseil-cpp}"
    (lib.cmakeBool "WITH_SUBMODULES_SYSTEM" true)
    (lib.cmakeOptionType "path" "LIBHIGHWAYHASH_LIBDIR" "${highwayhash}/lib")
    (lib.cmakeOptionType "path" "LIBHIGHWAYHASH_INCLUDE" "${highwayhash}/include")
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    abseil-cpp
    gbenchmark
    grpc
    gtest
    highwayhash # maybe?
    icu
    openssl
    protobuf
  ];

  passthru = { inherit highwayhash; };
})
