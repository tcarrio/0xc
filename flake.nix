{
  description = "0xc dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-formatter-pack.url = "github:Gerschtli/nix-formatter-pack";
    nix-formatter-pack.inputs.nixpkgs.follows = "nixpkgs";

    zola-github-action = {
      type = "github";
      owner = "shalzz";
      repo = "zola-deploy-action";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-formatter-pack, zola-github-action }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/ARM Linux
        "aarch64-linux" # 64-bit AMD Linux
        "x86_64-darwin" # 64-bit Intel/ARM macOS
        "aarch64-darwin" # 64-bit Apple Silicon
      ];

      # Helper to provide system-specific attributes
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = f: genAttrs allSystems (system: f {
        pkgs = import nixpkgs {
          inherit system;
        };
      });
    in
    {
      devShells = forAllSystems ({ pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              zola
            ];

            PROJECT_NAME = "0xc";

            shellHook = ''
              echo $ Started devshell for $PROJECT_NAME
              echo
              uname -v
              echo
              git --version
              echo
              echo "zola version $(zola --version)"
              echo
            '';
          };
        }
      );

      formatter = forAllSystems (system:
        nix-formatter-pack.lib.mkFormatter {
          pkgs = nixpkgs.legacyPackages.${system};
          config.tools = {
            alejandra.enable = false;
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
            statix.enable = true;
          };
        }
      );

      packages = forAllSystems ({ pkgs }:
        let
          bundleShellScript = { name, filePath, buildInputs, ... }:
            let
              command = (pkgs.writeScriptBin name (builtins.readFile filePath)).overrideAttrs(old: {
                buildCommand = "${old.buildCommand}\n patchShebangs $out";
              });
            in pkgs.symlinkJoin {
              inherit name;
              paths = [ command ] ++ buildInputs;
              buildInputs = [ pkgs.makeWrapper ];
              postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
            }
          ;
        in {
          deployAction = bundleShellScript { name = "deploy.sh"; filePath = "${zola-github-action}/entrypoint.sh"; buildInputs = with pkgs; [ git zola coreutils ]; };
        }
      );
    };

    nixConfig.bash-prompt = "\[0xc\]$ ";

}