import 'package:flutter/material.dart';

class CerchioConnessioneNFC extends StatelessWidget {
  Function()? tapHandler;
  String text;
  Color accentColor;

  CerchioConnessioneNFC(
    this.tapHandler,
    this.text,
    this.accentColor,
  );

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: tapHandler,
      child: Container(
        width: 300.0,
        height: 300.0,
        decoration: BoxDecoration(
          color: accentColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
