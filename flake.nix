{
  description = "A clj-nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    clj-nix.url = "github:jlesquembre/clj-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      clj-nix,
    }:

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        packages = {
          default = clj-nix.lib.mkCljApp {
            inherit pkgs;
            modules = [
              {
                projectSrc = lib.sources.sourceFilesBySuffices ./. [
                  ".clj"
                  "deps-lock.json"
                ];

                name = "de.hhu.fscs/was-letzte-tuer";
                main-ns = "de.hhu.fscs.was-letzte-tuer.core";
              }
            ];
          };

          deps-lock = clj-nix.packages.${system}.deps-lock;
        };
      }
    );
}
