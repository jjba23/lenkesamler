# lenkesamler

# Copyright © Josep Bigorra <jjbigorra@gmail.com>

# lenkesamler is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# lenkesamler is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with lenkesamler.  If not, see <https://www.gnu.org/licenses/>.

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
