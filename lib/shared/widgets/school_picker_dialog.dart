import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shafeea/features/auth/domain/entities/school_entity.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

/// A dialog widget for selecting a school during student registration.
///
/// Mirrors the structure and visual style of [CountryPickerDialog]:
/// glass-morphism container, debounced search field, radio-list, and
/// Cancel / Confirm footer buttons.
///
/// A synthetic "مستقل / بدون مدرسة" entry (value `null`) is always shown
/// at the top of the list so the user can explicitly opt out of a school.
class SchoolPickerDialog extends StatefulWidget {
  final List<SchoolEntity> schools;
  final SchoolEntity? initialSchool;

  /// Called once when the user taps Confirm with the selected school,
  /// or `null` if the user chose "مستقل / بدون مدرسة".
  final ValueChanged<SchoolEntity?> onSchoolSelected;

  const SchoolPickerDialog({
    super.key,
    required this.schools,
    required this.onSchoolSelected,
    this.initialSchool,
  });

  @override
  State<SchoolPickerDialog> createState() => _SchoolPickerDialogState();
}

class _SchoolPickerDialogState extends State<SchoolPickerDialog> {
  late List<SchoolEntity> _filtered;
  late FocusNode _focusNode;

  /// `null` represents "مستقل / بدون مدرسة".
  SchoolEntity? _tempSelected;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filtered = widget.schools;
    _tempSelected = widget.initialSchool;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filtered = query.trim().isEmpty
            ? widget.schools
            : widget.schools
                .where((s) => s.name.contains(query.trim()))
                .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.lightCream.withOpacity(0.1),
            insetPadding: const EdgeInsets.all(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: AppColors.accent12,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent70, width: 0.7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ───────────────────────────────────────────
                    Text(
                      'قم بتحديد المدرسة...',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightCream,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Search field ─────────────────────────────────────
                    TextField(
                      controller: _searchCtrl,
                      focusNode: _focusNode,
                      style: GoogleFonts.cairo(color: AppColors.lightCream),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن المدرسة',
                        hintStyle: GoogleFonts.cairo(
                          color: AppColors.lightCream70,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.lightCream,
                        ),
                        filled: true,
                        fillColor: AppColors.lightCream.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── List ─────────────────────────────────────────────
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.separated(
                          // +1 for the "independent / no school" sentinel row.
                          itemCount: _filtered.length + 1,
                          separatorBuilder: (_, __) => Divider(
                            color: AppColors.accent,
                            height: 1,
                            thickness: 1,
                          ),
                          itemBuilder: (_, i) {
                            // Index 0 is always the null sentinel.
                            if (i == 0) {
                              return Material(
                                color: AppColors.lightCream.withOpacity(0.05),
                                child: RadioListTile<SchoolEntity?>(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  tileColor: Colors.transparent,
                                  value: null,
                                  groupValue: _tempSelected,
                                  title: Text(
                                    'مستقل / بدون مدرسة',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.lightCream,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  secondary: Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.lightCream70,
                                    size: 22,
                                  ),
                                  onChanged: (_) {
                                    setLocalState(() {
                                      _tempSelected = null;
                                      _searchCtrl.clear();
                                      _focusNode.unfocus();
                                    });
                                  },
                                ),
                              );
                            }

                            final school = _filtered[i - 1];
                            return Material(
                              color: AppColors.lightCream.withOpacity(0.05),
                              child: RadioListTile<SchoolEntity?>(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                tileColor: Colors.transparent,
                                value: school,
                                groupValue: _tempSelected,
                                title: Text(
                                  school.name,
                                  style: GoogleFonts.cairo(
                                    color: AppColors.lightCream,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                secondary: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      color: AppColors.lightCream70,
                                      size: 22,
                                    ),
                                    if (school.city != null &&
                                        school.city!.isNotEmpty)
                                      Text(
                                        school.city!,
                                        style: GoogleFonts.cairo(
                                          color: AppColors.lightCream70,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                                onChanged: (sel) {
                                  setLocalState(() {
                                    _tempSelected = sel;
                                    _searchCtrl.text = sel?.name ?? '';
                                    _focusNode.unfocus();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Footer buttons ───────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.accent70),
                            ),
                            child: Text(
                              'إلغاء',
                              style: GoogleFonts.cairo(
                                color: AppColors.lightCream,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                            ),
                            onPressed: () {
                              widget.onSchoolSelected(_tempSelected);
                              Navigator.pop(context);
                            },
                            child: Text(
                              'تأكيد',
                              style: GoogleFonts.cairo(
                                color: AppColors.lightCream,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
