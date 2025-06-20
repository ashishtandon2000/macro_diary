library common;

import 'package:flutter/material.dart';

part "functions/prints.dart";
part 'widgets/loader.dart';



class Util {
  const Util();

  // g- group
  static const print = _appPrints();

  // w- widget
  static const wCircularLoader = _circularLoader;
}