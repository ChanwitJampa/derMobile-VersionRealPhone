import 'dart:math';

import 'package:flutter/material.dart';

class ColorPalette {
  static final ColorPalette primary = ColorPalette(<Color>[

    Color(0xFF2196F3),
    Color(0xFF90CAF9),
     Color(0xFF66BB6A),
    Color(0xFFA5D6A7),
   
    Color.fromARGB(201, 163, 166, 168),
    Color(0xFFFFEE58),
    Color(0xFFFFF59D),
    Color(0xFFEF9A9A),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFFCE93D8),
    Color(0xFFFFA726),
    Color(0xFFFFCC80),
    Color(0xFF26A69A),
    Color(0xFF80CBC4),
    Colors.black,
  ]);

  ColorPalette(List<Color> colors) : _colors = colors {
    assert(colors.isNotEmpty);
  }

  final List<Color> _colors;

  Color operator [](int index) => _colors[index % length];

  int get length => _colors.length;

  Color random(Random random) => this[random.nextInt(length)];
}