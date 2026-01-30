{ lib

, installPatchScript
, mkPatch
}:

patches:
#
# A list containing any combination of either:
#
# 1. Derivations created using mkPatch
# 2. Arguments to the mkPatch function
#

lib.concatStringsSep "\n" (
  builtins.map
    (x:
      if lib.isDerivation x && builtins.hasAttr "path" x then
        #
        # We enter here if `x == mkPatch args` for some arguments `args`
        #
        installPatchScript x
      else
        #
        # Otherwise we assume that `x` is the attribute set
        # required for a `mkPatch` call
        #
        installPatchScript (mkPatch x)
    )
    patches
)
