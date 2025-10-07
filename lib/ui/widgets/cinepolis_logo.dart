import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CinepolisLogo extends StatelessWidget {
  final double size;
  const CinepolisLogo({super.key, this.size = 100.0});

  @override
  Widget build(BuildContext context) {
    // Usamos el color primario del tema actual para que el logo se adapte.
    final color = Theme.of(context).colorScheme.primary;

    // Este es un logo simple en formato SVG, creado con código.
    // Representa una estrella estilizada, similar al logo de Cinépolis.
    final String svgString = '''
    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
      <polygon points="50,5 61,35 95,35 68,55 78,85 50,65 22,85 32,55 5,35 39,35" fill="$color"/>
    </svg>
    ''';

    return SvgPicture.string(
      svgString.replaceAll('"$color"', '"${_colorToHex(color)}"'),
      height: size,
      width: size,
    );
  }

  // Pequeña función de ayuda para convertir el color de Flutter a un string Hex.
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
}
