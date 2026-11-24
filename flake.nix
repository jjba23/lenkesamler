# lenkesamler
#
# SPDX-License-Identifier: MIT
# Copyright © Josep Bigorra <jjbigorra@gmail.com>

{
  description = "Lenkesamler - bookmark manager, sync tool and digital archive";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # The launcher is a bash script that shells out to util-linux and
      # coreutils, so the package is as portable as those are.
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          lenkesamler = pkgs.callPackage ./default.nix { };
          default = self.packages.${system}.lenkesamler;
        });

      apps = forAllSystems (system: {
        lenkesamler = {
          type = "app";
          program = "${self.packages.${system}.lenkesamler}/bin/lenkesamler";
        };
        default = self.apps.${system}.lenkesamler;
      });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.lenkesamler ];
            packages = with pkgs; [
              guile
              guile-json
              guile-gnutls
            ];
            shellHook = ''
              export GUILE_LOAD_PATH="$PWD/src''${GUILE_LOAD_PATH:+:$GUILE_LOAD_PATH}"
            '';
          };
        });
    };
}
