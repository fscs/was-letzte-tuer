{
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
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            clojure
          ];
        };

        packages = {
          default =
            clj-nix.lib.mkCljApp {
              inherit pkgs;
              modules = [
                {
                  projectSrc = lib.sources.sourceFilesBySuffices ./. [
                    ".clj"
                    ".edn"
                    ".webp"
                    ".html"
                    "deps-lock.json"
                  ];

                  name = "de.hhu.fscs/was-letzte-tuer";
                  main-ns = "de.hhu.fscs.was-letzte-tuer.core";

                }
              ];
            }
            // {
              meta.mainProgram = "was-letzte-tuer";
            };

          deps-lock = clj-nix.packages.${system}.deps-lock;
        };
      }
    )
    // {
      nixosModules.was-letzte-tuer = import ./module.nix { inherit (self) outputs; };
    };
}
