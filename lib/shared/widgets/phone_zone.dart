import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shafeea/core/models/countery_model.dart';
import 'package:shafeea/shared/widgets/country_picker_dialog.dart';

class PhoneZoneForm extends StatefulWidget {
  final TextEditingController zoneController;
  final TextEditingController phoneController;
  final CountryModel initialCountry;
  final String label;
  final VoidCallback? onCountryChanged;

  const PhoneZoneForm({
    super.key,
    required this.zoneController,
    required this.phoneController,
    required this.initialCountry,
    required this.label,
    this.onCountryChanged,
  });

  @override
  State<PhoneZoneForm> createState() => _PhoneZoneFormState();
}

class _PhoneZoneFormState extends State<PhoneZoneForm> {
  late CountryModel selectedCountry;
  final FocusNode _zoneFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    selectedCountry = widget.initialCountry;
  }

  @override
  void dispose() {
    // Do NOT dispose widget.zoneController / widget.phoneController —
    // they are owned by the parent widget.
    _zoneFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _openCountryPicker() {
    showDialog(
      context: context,
      builder: (_) => CountryPickerDialog(
        initialCountry: selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            selectedCountry = country;
            widget.zoneController.text = country.countryCallingCode;
            widget.onCountryChanged?.call();
          });
          _phoneFocus.requestFocus();
        },
        isCollingCode: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.onSurface.withOpacity(0.07)
                : colorScheme.primary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // ── Country flag + code ──────────────────────────────
              GestureDetector(
                onTap: _openCountryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flag.fromString(
                        selectedCountry.status,
                        height: 18,
                        width: 26,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${widget.zoneController.text}',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Divider ──────────────────────────────────────────
              Container(
                width: 1,
                height: 28,
                color: colorScheme.onSurface.withOpacity(0.15),
              ),

              // ── Phone number field ───────────────────────────────
              Expanded(
                child: TextFormField(
                  controller: widget.phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  cursorColor: colorScheme.primary,
                  decoration: InputDecoration(
                    hintText: widget.label,
                    hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  validator: (val) => (val == null || val.isEmpty)
                      ? "حقل ${widget.label} مطلوب"
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
