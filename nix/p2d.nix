{
  format ? false,
  lint ? false,
  craneLibDefault,
  fenix,
  stdenv,
  lib,
  patoh,
}:
let
  target = stdenv.targetPlatform.rust.rustcTarget;

  toolchain =
    pkgs:
    let
      system = pkgs.stdenv.buildPlatform.system;
    in
    fenix.packages.${system}.combine [
      fenix.packages.${system}.stable.minimalToolchain
      fenix.packages.${system}.stable.rustfmt
      fenix.packages.${system}.stable.clippy
      fenix.packages.${system}.targets.${target}.stable.rust-std
    ];

  craneLib = craneLibDefault.overrideToolchain (p: toolchain p);
  metadata = craneLib.crateNameFromCargoToml { cargoToml = ../p2d/Cargo.toml; };

  craneAction =
    if format then
      "cargoFmt"
    else if lint then
      "cargoClippy"
    else
      "buildPackage";

  crate = {
    meta = {
      mainProgram = "p2d";
      description = "A Pseudo-Boolean d-DNNF Compiler";
      homepage = "https://github.com/TUBS-ISF/p2d";
      license = lib.licenses.lgpl3Plus;
      platforms = lib.platforms.unix;
    };

    pname = metadata.pname;
    version = metadata.version;

    src = lib.fileset.toSource {
      root = ./..;
      fileset = lib.fileset.unions [
        (craneLib.fileset.commonCargoSources ./..)
        ../p2d/test_models
        ../p2d_opb/src/opb.pest
      ];
    };

    buildInputs = [ patoh.dev ];

    strictDeps = true;

    CARGO_BUILD_TARGET = target;
  };

  cargoArtifacts = craneLib.buildDepsOnly crate;
in
craneLib.${craneAction} (
  crate
  // {
    inherit cargoArtifacts;
    cargoClippyExtraArgs = "-- --deny warnings";
  }
)
