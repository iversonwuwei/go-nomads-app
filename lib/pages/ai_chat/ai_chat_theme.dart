import 'package:flutter/material.dart';

class AiChatTheme {
  AiChatTheme._();

  static const Color canvasTop = Color(0xFFF7EEDF);
  static const Color canvasBottom = Color(0xFFE3F2EC);
  static const Color shell = Color(0xFFF8F4ED);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2EBE1);
  static const Color panel = Color(0xE6FFFFFF);
  static const Color line = Color(0xFFE4D9CC);
  static const Color ink = Color(0xFF183B3A);
  static const Color inkSoft = Color(0xFF5E7873);
  static const Color teal = Color(0xFF1D6F67);
  static const Color tealDeep = Color(0xFF113E45);
  static const Color tealSoft = Color(0xFFB9E1D4);
  static const Color coral = Color(0xFFE78664);
  static const Color coralDeep = Color(0xFFCB5B43);
  static const Color codeBackground = Color(0xFF152B32);
  static const Color codeHeader = Color(0xFF214451);
  static const Color codeText = Color(0xFFE8F6F2);
  static const Color codeMuted = Color(0xFF8ACFBE);
  static const Color errorSoft = Color(0xFFFFE5D9);
  static const Color error = Color(0xFFB44C2F);
  static const Color shadow = Color(0x1A25423B);

  static const LinearGradient canvasGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [canvasTop, canvasBottom],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealDeep, teal, coral],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, coralDeep],
  );
}
