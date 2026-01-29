{ elmHome, elmVersion }:

drv: # A derivation of a patched package, i.e. one created with mkPatch
let
  packagesDir = "${elmHome}/${elmVersion}/packages";
  to = "${packagesDir}/${drv.path}";
  from = "${drv}/${drv.path}";
in
''
if [ -d ${to} ]; then
  echo "Patching from ${from} to ${to}"

  rm -r ${to}
  cp -R ${from} ${to}
  chmod -R +w ${to}
fi
''
