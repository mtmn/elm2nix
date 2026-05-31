{ fetchFromGitHub, stdenv, }:
{ fromOwner, toOwner, repo, version, rev, hash, }:
let path = "${toOwner}/${repo}/${version}";
in stdenv.mkDerivation {
  inherit version;

  pname = "${fromOwner}-${repo}";

  src = fetchFromGitHub {
    inherit repo rev hash;
    owner = fromOwner;
  };

  installPhase = ''
    root="$out/${path}"
    mkdir -p "$root"

    #
    # N.B. The following assumes the typical layout for a published Elm package.
    #
    # i.e. The elm.json file and the src directory both live at the root of the package.
    #
    # If that's not the case then you can override this installPhase.
    #
    cp elm.json "$root/elm.json"
    cp -R src "$root/src"
  '';

  passthru = { inherit path; };
}
