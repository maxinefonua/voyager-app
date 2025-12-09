import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LogoSvg extends StatelessWidget {
  final String logoSvgString = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="-4.25 -2 20 15">
  <path fill="currentColor" d="M14.514 10.962L-3.154 10.962L-3.135 11.588C-1.657 12.536 14.325 12.327 14.495 11.588M-0.746 7.108C1.425 7.5 4.432 6.309 4.896-1.82C9.826 1.373 9.981 3.915 13.794 11.51C3.386 9.559 3.898 9.806-0.746 7.108M-4.171 11.596L15.517 11.615L15.536 12.281C13.842 13.233-2.609 13.138-4.171 12.338"/>
</svg>
''';
  final double size;
  final Color color;
  const LogoSvg({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      logoSvgString,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
