import 'package:app/pages/widgets/reservationTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BoldLabelWithText extends StatelessWidget {
  final String label;
  final String text;
  final double fontSize;

  const BoldLabelWithText({
    Key? key,
    required this.label,
    required this.text,
    this.fontSize = 19.0, // default font size, can be overridden
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black, // default color, can be adjusted
        ),
        children: [
          TextSpan(
            text: label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: text,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
