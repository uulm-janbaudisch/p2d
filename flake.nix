{
  description = "A Pseudo-Boolean d-DNNF Compiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane/v0.21.2";
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
      crane,
      ...
    }:
    let
      lib = nixpkgs.lib;

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsStatic = pkgs.pkgsStatic;
          pkgsSelf = self.packages.${system};

          lib = pkgs.lib;
        in
        {
          default = pkgsSelf.p2d;

          p2d = pkgsStatic.callPackage ./nix/p2d.nix {
            craneLibDefault = crane.mkLib pkgs;
            inherit fenix;
            patoh = pkgsSelf.patoh;
          };

          patoh = pkgs.callPackage ./nix/patoh.nix { };

          container =
            let
              p2d = self.packages.${system}.p2d;
            in
            pkgs.dockerTools.buildLayeredImage {
              name = "p2d";
              contents = [
                p2d
                pkgs.time
              ];
              config = {
                Entrypoint = [ (lib.getExe p2d) ];
                Labels = {
                  "org.opencontainers.image.source" = "https://github.com/uulm-janbaudisch/p2d";
                  "org.opencontainers.image.description" = "A Pseudo-Boolean d-DNNF Compiler";
                };
              };
            };
        }
      );
      checks = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsSelf = self.packages.${system};

          defaultAttrs = {
            craneLibDefault = crane.mkLib pkgs;
            inherit fenix;
            patoh = pkgsSelf.patoh;
          };
        in
        {
          format = pkgs.callPackage ./nix/p2d.nix (defaultAttrs // { format = true; });
          lint = pkgs.callPackage ./nix/p2d.nix (defaultAttrs // { lint = true; });
        }
      );
    };
}
