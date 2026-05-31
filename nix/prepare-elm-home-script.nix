{
  dotElmLinks,
  elmHome,
}: {
  elmLock,
  registryDat,
}: ''
  echo "Prepare ${elmHome} and set ELM_HOME=${elmHome}"
  cp -LR "${dotElmLinks {inherit elmLock registryDat;}}" ${elmHome}
  chmod -R +w ${elmHome}
  export ELM_HOME="$PWD/${elmHome}"
''
