import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final void Function(DateTime)? onDateSelected;
  final TextEditingController controller;
  final IconData icon;
  final String label;

  const CustomDatePicker({
    super.key,
    this.onDateSelected,
    required this.controller,
    required this.icon,
    required this.label,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Inherit the current app theme fully
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              cancelButtonStyle: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              confirmButtonStyle: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateSelected?.call(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: widget.controller,
        readOnly: true,
        keyboardType: TextInputType.none,
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
          prefixIcon: Icon(
            widget.icon,
            color: colorScheme.primary.withOpacity(0.75),
            size: 20,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
        onTap: _pickDate,
      ),
    );
  }
}
