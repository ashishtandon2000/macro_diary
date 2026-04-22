class Print{
  const Print._();

  static debug(Object? object){
    print("#DEBUG || $object");
  }

  static error(Object? object){
    print("#ERROR || $object");
  }
}