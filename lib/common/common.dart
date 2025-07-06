library common;

import 'package:flutter/material.dart';

part "functions/prints.dart";
part 'functions/get_map_safely.dart';

part 'widgets/loader.dart';
part 'widgets/popup_Dialogs.dart';



class Util {
  const Util();

  // f- functions
  static const fGetMapSafely = getMapSafely;

  // g- group
  static const print = _appPrints();

  // w- widgets
  static const wCircularLoader = _circularLoader;
  static const wConfirmationDialog = _confirmationDialog; // Although it is a func but returns a widget and will be used like a widget
  static const wNullScreenMessage = _nullScreenMessage;
  static const wBottomNotifyMsg = _bottomNotifier;
}