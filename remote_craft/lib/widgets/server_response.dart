import 'package:flutter/material.dart';

final List<Color> _colorsDark = [
  Colors.black,
  Colors.blue,
  Colors.green,
  Colors.cyan,
  Colors.red,
  Colors.purple,
  Colors.orange,
  Colors.grey,
  Colors.grey[800],
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.cyan[300],
  Colors.red[300],
  Colors.purple[300],
  Colors.yellow,
  Colors.white,
  Colors.pink // Underline
];

final List<Color> _colorsLight = [
  Colors.white,
  Colors.blue,
  Colors.green,
  Colors.cyan,
  Colors.red,
  Colors.purple,
  Colors.orange,
  Colors.grey[800],
  Colors.grey,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.cyan[300],
  Colors.red[300],
  Colors.purple[300],
  Colors.yellow,
  Colors.black,
  Colors.pink // Underline
];

class ServerResponse extends StatelessWidget {
  final String response;
  final TextStyle style;

  ServerResponse(this.response, {this.style});

  TextSpan createSpan(BuildContext context, String text, TextStyle style, int color) {
    Brightness brightness = Theme.of(context).brightness;

    return TextSpan(
      text: text,
      style: style.copyWith(
        color: brightness == Brightness.dark ? _colorsDark[color] : _colorsLight[color]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = this.style ?? DefaultTextStyle.of(context).style;

    List<TextSpan> spans = List<TextSpan>();

    String currentSpan = '';
    int currentColor = 15;
    for (int c = 0; c < response.length; c++) {
      if (response.codeUnitAt(c) == 0xC2 && response.codeUnitAt(c + 1) == 0xA7) {
        spans.add(createSpan(context, currentSpan, style, currentColor));

        currentSpan = '';
        currentColor = int.parse('0x${response[c + 2]}');
        c += 2;
      } else currentSpan += response[c];
    }
    // Add final span
    spans.add(createSpan(context, currentSpan, style, currentColor));

    return Text.rich(TextSpan(
      children: spans,
      style: style
    ));
  }
}
