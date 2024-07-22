import 'package:flutter/material.dart';

class CapturedPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;

  const CapturedPiece(
      {super.key, required this.imagePath, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Image.asset(imagePath, color: isWhite? Colors.white : Colors.black,);
  }
}
