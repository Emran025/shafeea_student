import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool readOnly;
  final void Function(TextEditingController, String)? onTap;
  final String? Function(String?)? validator;
  final EdgeInsets padding;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.readOnly = false,
    this.validator,
    this.padding = const EdgeInsets.only(bottom: 14),
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: widget.padding,
      child: TextFormField(
        controller: widget.controller,
        readOnly: widget.readOnly,
        keyboardType: widget.isPassword
            ? TextInputType.visiblePassword
            : widget.keyboardType,
        obscureText: widget.isPassword && _obscureText,
        maxLines: widget.isPassword ? 1 : null,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
        ),
        cursorColor: colorScheme.primary,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.55),
            fontFamily: 'Cairo',
            fontSize: 13,
          ),
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.35),
            fontFamily: 'Cairo',
          ),
          prefixIcon: widget.keyboardType == TextInputType.phone
              ? null
              : Icon(
                  widget.prefixIcon,
                  color: colorScheme.primary.withOpacity(0.75),
                  size: 20,
                ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                )
              : widget.suffixIcon,
          filled: true,
          fillColor: isDark
              ? colorScheme.onSurface.withOpacity(0.07)
              : colorScheme.primary.withOpacity(0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1.8,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
        onTap: widget.onTap != null
            ? () => widget.onTap!(widget.controller, widget.label)
            : null,
        onSaved: (val) => widget.controller.text = val?.trim() ?? '',
        validator: widget.validator ??
            (val) => (val == null || val.isEmpty)
                ? "حقل ${widget.label} مطلوب"
                : null,
      ),
    );
  }
}
