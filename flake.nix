{
  description = "A collection of runnable Zig examples, used as the companion to the 'Zig Bytes' series.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { nixpkgs, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        { lib, pkgs, ... }:
        let
          # NOTE: keep this in sync with 'build.zig'
          zig = pkgs.zig_0_13;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [ zig ];
          };
        };
    };
}
