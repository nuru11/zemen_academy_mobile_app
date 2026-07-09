import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

Future<void>? _texReady;

Future<void> ensureTeXReady() =>
    _texReady ??= TeXRenderingServer.start();

class TeXGate extends StatefulWidget {
  const TeXGate({super.key, required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  State<TeXGate> createState() => _TeXGateState();
}

class _TeXGateState extends State<TeXGate> {
  late final Future<void> _ready = ensureTeXReady();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return widget.builder(context);
      },
    );
  }
}
