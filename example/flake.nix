{
  inputs = {
    elm2nix = {
      url = "./..";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, elm2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (elm2nix.lib.elm2nix pkgs)
          buildElmApplication
          generateRegistryDat
          prepareElmHomeScript
          mkPatch
          installPatchScript
          dotElmLinks
          symbolicLinksToPackagesScript
          fetchElmPackage
          ;

        elmLock = ./elm.lock;
        registryDat = generateRegistryDat {
          inherit elmLock;
        };

        exampleFetchElmPackage = fetchElmPackage {
          author = "elm";
          package = "browser";
          version = "1.0.2";
          sha256 = "0863nw2hhbpm3s03lm1imi5x28wwknzrwg2p79s5mydgvdvgwjf0";
        };

        exampleSymbolicLinksToPackagesScript = symbolicLinksToPackagesScript {
          inherit elmLock;
        };

        exampleDotElmLinks = dotElmLinks {
          inherit elmLock registryDat;
        };

        examplePrepareElmHomeScript = prepareElmHomeScript {
          inherit elmLock registryDat;
        };

        lydellBrowser = mkPatch {
          fromOwner = "lydell";
          toOwner = "elm";
          repo = "browser";
          version = "1.0.2";
          rev = "f5de544c8033d934285501f78f09e2eaf0171d55";
          hash = "sha256-29axLnzXcLDeKG+CBX49pjt2ZcYVdVg04XVnfAfImvI=";
        };

        lydellHtml = mkPatch {
          fromOwner = "lydell";
          toOwner = "elm";
          repo = "html";
          version = "1.0.1";
          rev = "b35c476a69f0ba9bf8282d8c15df65e63aefea8f";
          hash = "sha256-xyL/AvKdsxTl4RgfBCdTuWndM55eNM6whPD3YqptcKM=";
        };

        lydellVirtualDom = mkPatch {
          fromOwner = "lydell";
          toOwner = "elm";
          repo = "virtual-dom";
          version = "1.0.5";
          rev = "e1fae6aabd65539db2c94a98220a45cfc624b633";
          hash = "sha256-XpbRMCpIx151eHHoph7wkGYhtDp5bTBwUOefiWKItOc=";
        };

        omnibsElmCss = mkPatch {
          fromOwner = "omnibs";
          toOwner = "rtfeldman";
          repo = "elm-css";
          version = "18.0.0";
          rev = "e54998ce73b64c374b1457d5734c85d3f5b909fb";
          hash = "sha256-rmil+7lAKUm7Fm0MCba23xyCA0CWrDb1ej5gPeXS2oU=";
        };

        installLydellBrowserScript = installPatchScript lydellBrowser;

        installLydellHtmlScript = installPatchScript lydellHtml;

        installLydellVirtualDomScript = installPatchScript lydellVirtualDom;

        installOmnibsElmCssScript = installPatchScript omnibsElmCss;

        example = buildElmApplication {
          name = "example";
          src = ./.;
          elmLock = ./elm.lock;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "example";

          packages = [
            elm2nix.packages.${system}.default
            pkgs.elmPackages.elm
            pkgs.elmPackages.elm-format
            pkgs.elmPackages.elm-json
            pkgs.elmPackages.elm-review
            pkgs.elmPackages.elm-test
          ];

          shellHook = ''
            export PS1="($name)\n$PS1"
          '';
        };

        packages = rec {
          inherit
            exampleFetchElmPackage
            exampleDotElmLinks
            example
            lydellBrowser
            lydellHtml
            lydellVirtualDom
            omnibsElmCss;

          default = example;

          debuggedExample = example.override {
            enableDebugger = true;
            output = "debugged.js";
          };

          formattingCheckedExample = example.override {
            doElmFormat = true;
            elmFormatSourceFiles = [ "review/src" "src" "tests" ];
            output = "formatting-checked.js";
          };

          elmSafeVirtualDomExample = example.override {
            elmPackagePatches = [
              lydellBrowser
              lydellHtml
              lydellVirtualDom
            ];
          };

          #
          # N.B. The omnibsElmCss patch won't be installed since we haven't installed
          #      rtfeldman/elm-css version 18.0.0 into our example project.
          #
          # Steps to make it work:
          #
          # 1. elm install rtfeldman/elm-css
          # 2. elm2nix lock elm.json review/elm.json
          # 3. nix build .#elmSafeVirtualDomElmCssExample -L
          #
          elmSafeVirtualDomElmCssExample = example.override {
            elmPackagePatches = [
              lydellBrowser
              omnibsElmCss
              lydellVirtualDom
            ];
          };

          testedExample = formattingCheckedExample.override {
            doElmTest = true;
            output = "tested.js";
          };

          reviewedExample = testedExample.override {
            doElmReview = true;
            output = "reviewed.js";
          };

          optimizedExample = reviewedExample.override {
            enableOptimizations = true;
            output = "optimized.js";
          };

          optimized2Example = optimizedExample.override {
            optimizeLevel = 2;
            output = "optimized2.js";
          };

          optimized3Example = optimizedExample.override {
            optimizeLevel = 3;
            output = "optimized3.js";
          };

          combined1Example = optimizedExample.override {
            entry = [ "src/Main.elm" "src/Workshop.elm" ];
            output = "combined1.js";
          };

          #
          # N.B.: The following isn't allowed since elm-optimize-level-2 doesn't support multiple entries.
          #
          # When you attempt to build this derivation it will fail as expected.
          #
          combined2Example = optimized2Example.override {
            entry = [ "src/Main.elm" "src/Workshop.elm" ];
            output = "combined2.js";
          };

          minifiedExample = optimized2Example.override {
            doMinification = true;
            useTerser = true;
            output = "minified.js";
          };

          compressedExample = minifiedExample.override {
            doCompression = true;
            output = "compressed.js";
          };

          reportedExample = compressedExample.override {
            doReporting = true;
            output = "reported.js";
          };

          hashedExample = reportedExample.override {
            doContentHashing = true;
            hashLength = 12;
            keepFilesWithNoHashInFilenames = true;
            output = "hashed.js";
          };

          #
          # N.B. The finalExample derivation is equivalent to the hashedExample derivation.
          #
          finalExample = buildElmApplication {
            name = "example";
            src = ./.;
            elmLock = ./elm.lock;

            doElmFormat = true;
            elmFormatSourceFiles = [ "review/src" "src" "tests" ];

            doElmTest = true;
            doElmReview = true;

            enableOptimizations = true;
            optimizeLevel = 2;

            doMinification = true;
            useTerser = true;

            doCompression = true;
            doReporting = true;

            doContentHashing = true;
            hashLength = 12;
            keepFilesWithNoHashInFilenames = true;

            output = "hashed.js";
          };
        };

        scripts = {
          inherit
            examplePrepareElmHomeScript
            exampleSymbolicLinksToPackagesScript
            installLydellBrowserScript
            installLydellHtmlScript
            installLydellVirtualDomScript
            installOmnibsElmCssScript;
        };
      }
    );
}
