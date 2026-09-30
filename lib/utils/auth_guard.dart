import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_academy/services/auth.dart';
import 'package:vector_academy/utils/constants/constants.dart';
import 'package:vector_academy/utils/home_tab_controllers.dart';
import 'package:vector_academy/views/views.dart';

const String authReturnRouteKey = 'returnRoute';
const String authCheckoutArgsKey = 'checkoutArgs';

bool get isCurrentUserAuthenticated =>
    Get.isRegistered<AuthService>() &&
    Get.find<AuthService>().isAuthenticated;

String get startupRoute {
  if (is_ios && !isCurrentUserAuthenticated) {
    return VIEWS.login.path;
  }
  return VIEWS.home.path;
}

void goToStartupRoute() {
  final route = startupRoute;
  if (route == VIEWS.login.path) {
    Get.offAllNamed(route);
    Future.microtask(clearHomeTabControllers);
    return;
  }

  Get.offAll(() => const Scaffold(body: SizedBox.shrink()));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    clearHomeTabControllers();
    Get.offAllNamed(VIEWS.home.path);
  });
}

bool requireAuthForPurchase({
  Map<String, dynamic>? checkoutArgs,
  bool replace = false,
}) {
  if (Get.isRegistered<AuthService>() &&
      Get.find<AuthService>().isAuthenticated) {
    return true;
  }

  final arguments = {
    authReturnRouteKey: VIEWS.payments.path,
    authCheckoutArgsKey: checkoutArgs,
  };
  if (replace) {
    Get.offNamed(VIEWS.register.path, arguments: arguments);
  } else {
    Get.toNamed(VIEWS.register.path, arguments: arguments);
  }
  return false;
}

Map<String, dynamic>? captureAuthRedirectArgs([dynamic rawArgs]) {
  final args = rawArgs ?? Get.arguments;
  if (args is Map) {
    return Map<String, dynamic>.from(args);
  }
  return null;
}

void navigateAfterAuth([Map<String, dynamic>? redirectArgs]) {
  final args = redirectArgs ?? captureAuthRedirectArgs();
  final returnRoute = args?[authReturnRouteKey] as String?;
  final checkoutArgs = args?[authCheckoutArgsKey];

  clearHomeTabControllers();
  Get.offAllNamed(VIEWS.home.path);
  if (returnRoute != null && returnRoute.isNotEmpty) {
    Future.microtask(() {
      Get.toNamed(returnRoute, arguments: checkoutArgs);
    });
  }
}
