{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    plover-update.url = "github:FirelightFlagboy/nixpkgs/update-plover-4.0.0.dev12";
  };

  outputs = { self, nixpkgs, plover-update }:
    let
      system = "aarch64-linux";

      overlay = final: prev: {
        plover.dev = plover-update.legacyPackages.${prev.system}.plover.dev;
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };

      plover-base = pkgs.plover.dev;

      self-pkgs = self.packages.${system};
    in
    {
      packages.${system} = rec {
        plover-wtype-output = pkgs.python310Packages.buildPythonPackage {
          name = "plover-wtype-output";
          src = pkgs.fetchFromGitHub {
            owner = "svenkeidel";
            repo = "plover-wtype-output";
            rev = "b31b9432defa2edbc087d3f36ee2cfec28244873";
            sha256 = "sha256-UlNlGG1ml40bDn1CQnsibXRrshokAnszUQRQZeAm+xs=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          propagatedBuildInputs = [ pkgs.wtype ];
        };
        plover-dotool-output = pkgs.python310Packages.buildPythonPackage {
          name = "plover-dotool-output";
          src = pkgs.fetchFromGitHub {
            owner = "halbGefressen";
            repo = "plover-output-dotool";
            rev = "25e7df1a116672163256ccef85cfd91f7e76b9cf";
            sha256 = "sha256-Fl4/MmXS3NZqgR1E/vl8iJizSeRyhDLH4bhLy92upqY=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          propagatedBuildInputs = [ pkgs.dotool ];
        };

        plover-dict-commands = pkgs.python310Packages.buildPythonPackage {
          name = "plover-dict-commands";
          src = pkgs.fetchFromGitHub {
            owner = "koiOates";
            repo = "plover_dict_commands";
            rev = "5dceddc0830fb5a72679d62995f27b2e49850998";
            sha256 = "sha256-PXsYMqJz8sxgloEtiwxxt6Eo0hyFp5oW0homIAYPz6A=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          propagatedBuildInputs = [ pkgs.python310Packages.setuptools pkgs.python310Packages.setuptools-scm ];
        };

        plover-last-translation = pkgs.python310Packages.buildPythonPackage {
          name = "plover-last-translation";
          src = pkgs.fetchFromGitHub {
            owner = "nsmarkop";
            repo = "plover_last_translation";
            rev = "b8c7d75e2d54cfdcbf7729b325b8446d2ea947b9";
            sha256 = "sha256-59kYnU8i4USeyZEcXRetBjbslQgo3kjb0zAnxcqH4M8=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          # propagatedBuildInputs = [];
        };

        plover-modal-dictionary = pkgs.python310Packages.buildPythonPackage {
          name = "plover-modal-dictionary";
          src = pkgs.fetchFromGitHub {
            owner = "Kaoffie";
            repo = "plover_modal_dictionary";
            rev = "086f9784377454ace45c333d21ea8ca2666b0a06";
            sha256 = "sha256-d5BYkjeGXfoYQibjr5wQFUmXU69dNrewkJ/Gi4c9eEI=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          # propagatedBuildInputs = [];
        };

        plover-python-dictionary = pkgs.python310Packages.buildPythonPackage {
          name = "plover-python-dictionary";
          src = pkgs.fetchFromGitHub {
            owner = "openstenoproject";
            repo = "plover_python_dictionary";
            rev = "8ff565b892f5e2153adfc800fd9a5b2c90989862";
            sha256 = "sha256-WZO4/255/Mn71AT3Lsz8Ck17TU6AcDTX2pChPpuoj8M=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          # propagatedBuildInputs = [];
        };

        plover-stitching = pkgs.python310Packages.buildPythonPackage {
          name = "plover-stitching";
          src = pkgs.fetchFromGitHub {
            owner = "TheaMorin";
            repo = "plover_stitching";
            rev = "7e75093beda5fbb1a161359072095d1679219def";
            sha256 = "sha256-Md3LIQ73CAJlA91hfVdZZp9RJElINHYfiFFBBOYrIgs=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          # propagatedBuildInputs = [];
        };

        plover-lapwing-aio = pkgs.python310Packages.buildPythonPackage {
          name = "plover-lapwing-aio";
          src = pkgs.fetchFromGitHub {
            owner = "aerickt";
            repo = "plover-lapwing-aio";
            rev = "c4077183722c59e6eee29854b3adc6bce4714a64";
            sha256 = "sha256-XcFdNk5IVpfVewMEAjajvATUNmBtvK9SyPwg/nNDxPw=";
          };

          buildInputs = [ plover-base ];
          dontWrapQtApps = true;
          propagatedBuildInputs = [
            plover-stitching
            plover-python-dictionary
            plover-modal-dictionary
            plover-last-translation
            plover-dict-commands
          ];
        };

        plover.dev = plover-base;
        plover-wtype = plover-base.overrideAttrs
          (old: { propagatedBuildInputs = old.propagatedBuildInputs ++ [ plover-wtype-output ]; });
        plover-dotool = plover-base.overrideAttrs
          (old: { propagatedBuildInputs = old.propagatedBuildInputs ++ [ plover-dotool-output plover-lapwing-aio ]; });
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ plover-base self-pkgs.plover-wtype-output self-pkgs.plover-dotool-output ];
      };
    };
}
