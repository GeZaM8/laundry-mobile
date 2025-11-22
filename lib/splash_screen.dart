import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _blueBg = false;
  bool _showText = false;

  static const Color _brandBlue = Color(0xFF0079B9);
  static const _tBlank = Duration(milliseconds: 600);
  static const _tLogoHold = Duration(milliseconds: 1200);
  static const _tBgTransition = Duration(milliseconds: 700);
  static const _tTextAppearDelay = Duration(milliseconds: 900);
  static const _tFinishHold = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(_tBlank);
    if (!mounted) return;
    setState(() => _showLogo = true);

    await Future.delayed(_tLogoHold);
    if (!mounted) return;
    setState(() => _blueBg = true);

    await Future.delayed(_tTextAppearDelay);
    if (!mounted) return;
    setState(() => _showText = true);

    await Future.delayed(_tFinishHold);
    if (!mounted) return;
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = _blueBg ? _brandBlue : Colors.white;

    return Scaffold(
      body: AnimatedContainer(
        duration: _tBgTransition,
        curve: Curves.easeInOut,
        color: bg,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: !_showLogo
                ? const SizedBox.shrink(key: ValueKey('blank'))
                : !_blueBg
                ? Image.asset(
                    'birulogo.png',
                    key: const ValueKey('logo-blue-on-white'),
                    width: 84,
                    height: 84,
                  )
                : !_showText
                ? Image.asset(
                    'putihlogo.png',
                    key: const ValueKey('logo-white-on-blue'),
                    width: 84,
                    height: 84,
                  )
                : Image.asset(
                    'teksputih.png',
                    key: const ValueKey('text-white-on-blue'),
                    height: 320,
                    width: 320,
                    filterQuality: FilterQuality.medium,
                  ),
          ),
        ),
      ),
    );
  }
}
