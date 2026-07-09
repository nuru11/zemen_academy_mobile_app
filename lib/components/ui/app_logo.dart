import 'package:flutter/material.dart';
import 'package:vector_academy/config/app_config.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 120,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      logoAsset,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
