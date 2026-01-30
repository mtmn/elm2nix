{ haskellPackages, lib }:

let
  fs = lib.fileset;
in
(haskellPackages.callPackage ./generated/elm2nix.nix {}).overrideAttrs (old: {
  src = fs.toSource {
    root = ../.;
    fileset = fs.unions [
      ../app
      ../src
      ../test
      ../elm2nix.cabal
      ../LICENSE
    ];
  };

  #
  # N.B. Even though `doCheck = false` by default I add this `preCheck`
  #      to ensure that downstream users don't have to worry about it.
  #
  preCheck = (old.preCheck or "") + ''
    export HSPEC_SKIP="(skip)"
  '';
})
