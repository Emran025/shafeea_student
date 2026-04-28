import 'package:flutter/material.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

class CustomTimePicker extends StatefulWidget {
  final void Function(TimeOfDay)? onTimeSelected;
  final TextEditingController controller;
  final IconData icon;
  final String label;

  const CustomTimePicker({
    super.key,
    this.onTimeSelected,
    required this.controller,
    required this.icon,
    required this.label,
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor:
                  isDark ? AppColors.mediumDark : Colors.white,
              hourMinuteTextColor: colorScheme.onSurface,
              dialHandColor: colorScheme.primary,
              dialBackgroundColor: isDark
                  ? AppColors.darkBackground
                  : colorScheme.primary.withOpacity(0.08),
              dialTextColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
              entryModeIconColor: colorScheme.primary,
              helpTextStyle: TextStyle(
                fontFamily: 'Cairo',
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              hourMinuteColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.08),
              ),
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
            colorScheme: colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      widget.onTimeSelected?.call(picked);
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
        onTap: _pickTime,
      ),
    );
  }
}
