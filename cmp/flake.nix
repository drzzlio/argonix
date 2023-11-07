{
  description = "Argonix Jobs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  outputs = inputs@{ flake-parts, dream2nix, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        shell = {
          languages.javascript.enable = true;
          languages.typescript.enable = true;

          imports = [ ];

          env = {
            ROARR_LOG = "true";
          };

          packages = with pkgs; [
          ];
        };

        package = dream2nix.lib.evalModules {
          packageSets.nixpkgs = pkgs;
          modules = [
            {
              # Package the reconciliation script
              imports = [
                dream2nix.modules.dream2nix.nodejs-package-lock-v3
                dream2nix.modules.dream2nix.nodejs-granular-v3
              ];

              nodejs-package-lock-v3 = {
                packageLockFile = ./package-lock.json;
              };

              nodejs-granular-v3 = {
                buildScript = ''
                  echo "#!/usr/bin/node"|cat - <(tsc ./reconcile.ts --outFile /dev/stdout) > reconcile.js
                  chmod +x ./reconcile.js
                  patchShebangs .
                '';
              };

              name = pkgs.lib.mkForce "reconcile";
              version = pkgs.lib.mkForce "1.0.0";

              mkDerivation = {
                src = pkgs.lib.cleanSource ./.;
              };
            }
          ];
        };
      in
      {
        packages.reconcile = package;
        packages.image = pkgs.dockerTools.buildLayeredImage {
          name = "argonix-jobs";
          contents = [
            pkgs.git
          ];
          config = {
            Cmd = ["${package}/bin/reconcile"];
          };
        };

        devenv.shells.default = shell;

        # Shell to run Job reconciliation logic in CMP
        devenv.shells.jobrecon = pkgs.lib.mkMerge [
          shell
          {
            packages = [
              pkgs.git
              package
            ];
          }
        ];

        # argonix-jobs runtime shell
        devenv.shells.ci = pkgs.lib.mkMerge [
          shell
          {
            scripts.ci.exec = ''
              echo hello
            '';
          }
        ];

      };
    };
}
