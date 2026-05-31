{fetchzip}: {
  author,
  package,
  version,
  sha256,
}:
fetchzip {
  name = "${author}-${package}-${version}";
  url = "https://github.com/${author}/${package}/archive/${version}.tar.gz";
  meta.homepage = "https://github.com/${author}/${package}";
  inherit sha256;
}
