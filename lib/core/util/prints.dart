class _appPrints{
  const _appPrints();

  debug(Object? object){
    print("#DEBUG || $object");
  }

  error(Object? object){
    print("#ERROR || $object");
  }
}