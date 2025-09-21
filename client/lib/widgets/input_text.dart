import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextStyle? textStyle;   // optional text style
  final Color? borderColor;     // optional border color
  final Color? fillColor;       // optional background fill color
  final TextStyle? hintStyle;   // optional hint style

  const InputText({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.textStyle,
    this.borderColor,
    this.fillColor,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: textStyle,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: hintStyle,
        filled: fillColor != null,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: borderColor ?? Colors.grey,
          ),
        ),
      ),
    );
  }
}
