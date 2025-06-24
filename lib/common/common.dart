library common;

import 'package:flutter/material.dart';
import 'package:macro_diary/common/functions/get_map_safely.dart';

part "functions/prints.dart";
part 'widgets/loader.dart';



class Util {
  const Util();

  // f- functions
  static const fGetMapSafely = getMapSafely;

  // g- group
  static const print = _appPrints();

  // w- widget
  static const wCircularLoader = _circularLoader;
}