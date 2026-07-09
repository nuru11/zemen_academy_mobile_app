import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String _homeRoutePath = '/home';

/// Pops the current route using GetX, with Navigator fallback and home fallback.
void safePop<T>({T? result}) {
  final nav = Get.key.currentState;
  if (nav != null && nav.canPop()) {
    Get.back<T>(result: result);
    return;
  }
  final ctx = Get.context;
  if (ctx != null && Navigator.of(ctx).canPop()) {
    Navigator.of(ctx).pop<T>(result);
    return;
  }
  if (Get.currentRoute != _homeRoutePath) {
    Get.until((route) => route.settings.name == _homeRoutePath);
  }
}
