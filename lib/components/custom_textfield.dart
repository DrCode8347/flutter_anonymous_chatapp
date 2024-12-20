import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  CustomTextfield(
      {required this.controller,
      this.obscureText,
      this.readOnly,
      this.fieldPadding,
      this.errorText,
      this.hintText,
      this.borderColor,
      this.borderWidth,
      this.onChange,
      super.key});

  EdgeInsets? fieldPadding;
  bool? readOnly;
  bool? obscureText;
  TextEditingController? controller;
  Color? borderColor;
  double? borderWidth;
  String? hintText;
  String? errorText;
  Function(String)? onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: fieldPadding ?? EdgeInsets.all(8.0),
      child: TextField(
        focusNode: FocusNode(),
        readOnly: readOnly ?? false,
        obscureText: obscureText ?? false,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(width: borderWidth ?? 4),
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: borderColor ?? Theme.of(context).primaryColor,
                  width: borderWidth ?? 2),
              borderRadius: BorderRadius.circular(10)),
          hintText: hintText ?? '',
          errorText: errorText,
        ),
        onChanged: onChange,
      ),
    );
  }
}
