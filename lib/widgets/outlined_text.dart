import 'package:flutter/cupertino.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double strokeWidth;
  final Color strokeColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const OutlinedText({
    super.key,
    required this.text,
    this.style,
    this.strokeWidth = 2.0,
    this.strokeColor = const Color(0x66000000),
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle();
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: baseStyle,
        ),
      ],
    );
  }
}
