import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    this.btnName,
    this.fontsize,
    this.btnHeight,
    this.btnWidth,
    this.borderRadius,
    this.btnColor,
    this.btnPadding,
    this.child,
    required this.onTap,
    super.key,
  });

  final double? btnWidth;
  final double? btnHeight;
  final Color? btnColor;
  final BorderRadius? borderRadius;
  final String? btnName;
  final Widget? child;
  final EdgeInsets? btnPadding;
  final double? fontsize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: btnPadding ?? EdgeInsets.all(8.0),
      child: SizedBox(
        width: btnWidth ?? double.infinity,
        height: btnHeight ?? 45,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                btnColor ?? Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(10),
            ),
            padding: EdgeInsets.zero, // Ensures consistent height and width
          ),
          child: Center(
            child: child ??
                Text(
                  btnName ?? 'Button',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: fontsize ?? 16,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
