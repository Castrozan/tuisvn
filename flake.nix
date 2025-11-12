{
  description = "Tuisvn: Terminal user interface for Subversion";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.buildGoModule {
            pname = "tuisvn";
            version = "0.1.0";

            src = ./.;

            vendorHash = "sha256-lJTmVthk692wa0ACr9Xkf4Gt3fTqDekBed3RG1LOe9I=";

            nativeBuildInputs = [ pkgs.makeWrapper ];

            postInstall = ''
              wrapProgram $out/bin/tuisvn \
                --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.subversion ]}
            '';

            meta = with pkgs.lib; {
              description = "Terminal user interface for Subversion";
              homepage = "https://github.com/YoshihideShirai/tuisvn";
              license = licenses.mit;
              maintainers = [ ];
              mainProgram = "tuisvn";
            };
          };
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/tuisvn";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            go-tools
            subversion
          ];

          shellHook = ''
            echo "tuisvn development environment"
            echo "Go version: $(go version)"
            echo "SVN version: $(svn --version --quiet)"
          '';
        };
      }
    );
}
