/// Can handle extracting (string, int, bool, list & map) from a map, returning datatype's 0 value in case of any error
dynamic getMapSafely<valueType>({required Map data, required String key}) {
  try {
    valueType val = data[key] as valueType;
    return val;
  } catch (err) {
    print("#DEBUG #ONETIME : not working with type $valueType with err $err");
    switch (valueType) {
      case String:
        return "";
      case int:
        return 0;
      case double:
        return 0.0;
      case bool:
        return false;
      case List:
        return [];
      case Map:
        return {};
      default:
        return null;
    }
  }
}
