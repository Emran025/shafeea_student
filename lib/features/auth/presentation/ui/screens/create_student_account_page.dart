import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafeea/core/models/gender.dart';

// --- Architecture Imports ---
import 'package:shafeea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shafeea/features/auth/domain/entities/student_applicant.dart';

// --- Shared Widgets & Core ---
import 'package:shafeea/shared/themes/app_theme.dart';
import 'package:shafeea/core/constants/countries_names.dart';
import 'package:shafeea/shared/func/date_format.dart';
import 'package:shafeea/shared/widgets/country_picker_dialog.dart';
import 'package:shafeea/shared/widgets/custom_text_field.dart';
import 'package:shafeea/shared/widgets/phone_zone.dart';
import 'package:shafeea/shared/widgets/pick_date.dart';
import 'package:shafeea/shared/widgets/pick_time.dart';

import '../../../../../core/models/countery_model.dart';

class CreateStudentAccountPage extends StatefulWidget {
  const CreateStudentAccountPage({super.key});

  @override
  State<CreateStudentAccountPage> createState() =>
      _CreateStudentAccountPageState();
}

class _CreateStudentAccountPageState extends State<CreateStudentAccountPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Controllers ---
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  late final TextEditingController _confirmPassCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _birthDateCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _phoneZoneCtrl;
  late final TextEditingController _whatsAppPhoneCtrl;
  late final TextEditingController _whatsAppZoneCtrl;
  late final TextEditingController _qualificationCtrl;
  late final TextEditingController _memorizationCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _residenceCtrl;
  late final TextEditingController _timeCtrl;

  // --- State Variables ---
  late CountryModel selectedPhoneZone;
  late CountryModel selectedWhatsAppZone;
  late CountryModel selectedCountry;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initCountries();
  }

  void _initControllers() {
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
    _confirmPassCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _genderCtrl = TextEditingController(text: "Male");
    _birthDateCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _phoneZoneCtrl = TextEditingController();
    _whatsAppPhoneCtrl = TextEditingController();
    _whatsAppZoneCtrl = TextEditingController();
    _qualificationCtrl = TextEditingController();
    _memorizationCtrl = TextEditingController();
    _countryCtrl = TextEditingController();
    _residenceCtrl = TextEditingController();
    _timeCtrl = TextEditingController();
  }

  void _initCountries() {
    // تعيين قيم افتراضية آمنة
    selectedPhoneZone = countries.firstWhere(
      (c) => c.countryCallingCode == 'YE',
      orElse: () => countries.first,
    );
    selectedWhatsAppZone = selectedPhoneZone;
    selectedCountry = selectedPhoneZone;

    _phoneZoneCtrl.text = selectedPhoneZone.countryCallingCode;
    _whatsAppZoneCtrl.text = selectedWhatsAppZone.countryCallingCode;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _bioCtrl.dispose();
    _genderCtrl.dispose();
    _birthDateCtrl.dispose();
    _phoneCtrl.dispose();
    _phoneZoneCtrl.dispose();
    _whatsAppPhoneCtrl.dispose();
    _whatsAppZoneCtrl.dispose();
    _qualificationCtrl.dispose();
    _memorizationCtrl.dispose();
    _countryCtrl.dispose();
    _residenceCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("إنشاء حساب طالب جديد"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        // الأيقونات والنص تأتي من AppBarTheme في AppThemes
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) => _handleBlocListener(context, state),
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader(context, "المعلومات الأساسية"),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: _nameCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                      label: "الاسم الثلاثي",
                      keyboardType: TextInputType.name,
                    ),
                    CustomTextField(
                      controller: _bioCtrl,
                      prefixIcon: Icons.info_outline_rounded,
                      label: "نبذة تعريفية",
                      keyboardType: TextInputType.multiline,
                      // maxLines: 2, // إذا كان الودجت يدعمها
                    ),

                    const SizedBox(height: 25),
                    _buildSectionHeader(context, "بيانات الدخول"),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: _emailCtrl,
                      prefixIcon: Icons.email_outlined,
                      label: "البريد الإلكتروني",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: _passCtrl,
                      prefixIcon: Icons.lock_outline_rounded,
                      label: "كلمة المرور",
                      isPassword: true,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    CustomTextField(
                      controller: _confirmPassCtrl,
                      prefixIcon: Icons.lock_reset_rounded,
                      label: "تأكيد كلمة المرور",
                      isPassword: true,
                      validator: (val) {
                        if (val != _passCtrl.text) {
                          return "كلمات المرور غير متطابقة";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),
                    _buildSectionHeader(context, "البيانات الشخصية"),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildGenderDropdown(context)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: CustomDatePicker(
                            controller: _birthDateCtrl,
                            icon: Icons.calendar_month_outlined,
                            label: "الميلاد",
                            onDateSelected: (date) {
                              _birthDateCtrl.text = formatDate(date);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // حقول الموقع
                    CustomTextField(
                      controller: _countryCtrl,
                      prefixIcon: Icons.flag_outlined,
                      label: "محل الميلاد",
                      readOnly: true,
                      onTap: (ctrl, _) => _showCountryDialog(ctrl),
                    ),
                    CustomTextField(
                      controller: _residenceCtrl,
                      prefixIcon: Icons.location_on_outlined,
                      label: "بلد الإقامة",
                      readOnly: true,
                      onTap: (ctrl, _) => _showCountryDialog(ctrl),
                    ),

                    const SizedBox(height: 25),
                    _buildSectionHeader(context, "التواصل"),
                    const SizedBox(height: 15),
                    PhoneZoneForm(
                      phoneController: _phoneCtrl,
                      zoneController: _phoneZoneCtrl,
                      initialCountry: selectedPhoneZone,
                      label: "رقم الهاتف",
                      onCountryChanged: () => _updatePhoneZone(
                        _phoneZoneCtrl,
                        (c) => selectedPhoneZone = c,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PhoneZoneForm(
                      phoneController: _whatsAppPhoneCtrl,
                      zoneController: _whatsAppZoneCtrl,
                      initialCountry: selectedWhatsAppZone,
                      label: "واتسآب",
                      onCountryChanged: () => _updatePhoneZone(
                        _whatsAppZoneCtrl,
                        (c) => selectedWhatsAppZone = c,
                      ),
                    ),
                    CustomTimePicker(
                      controller: _timeCtrl,
                      icon: Icons.access_time_rounded,
                      label: "أفضل وقت للتواصل",
                      onTimeSelected: (time) {
                        _timeCtrl.text = time.format(context);
                      },
                    ),

                    const SizedBox(height: 25),
                    _buildSectionHeader(context, "المعلومات القرآنية"),
                    const SizedBox(height: 15),
                    CustomTextField(
                      controller: _qualificationCtrl,
                      prefixIcon: Icons.school_outlined,
                      label: "المؤهل العلمي",
                    ),
                    CustomTextField(
                      controller: _memorizationCtrl,
                      prefixIcon: Icons.menu_book_rounded,
                      keyboardType: TextInputType.number,
                      label: "عدد الأجزاء المحفوظة",
                    ),

                    const SizedBox(height: 40),

                    // --- زر التسجيل ---
                    if (state.registrationStatus ==
                        StudentRegistrationStatus.submitting)
                      Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    else
                      SizedBox(
                        height: 56, // ارتفاع مريح للزر
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: Text(
                            "تسجيل الحساب",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widgets Helpers ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onBackground.withOpacity(0.1),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      value: _genderCtrl.text.isEmpty ? "Male" : _genderCtrl.text,
      isDense: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
        size: 24,
      ),

      decoration: InputDecoration(
        labelText: "الجنس",
        prefixIcon: Icon(
          Icons.people_alt_outlined,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          size: 22,
        ),

        filled: true,
        fillColor: AppColors.lightCream.withOpacity(0.1),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 13.5,
          horizontal: 12,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      dropdownColor: theme.colorScheme.surface,

      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onBackground,
      ),

      items: const [
        DropdownMenuItem(value: "Male", child: Text("ذكر")),
        DropdownMenuItem(value: "Female", child: Text("أنثى")),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _genderCtrl.text = val);
      },
    );
  }

  // --- Logic Helpers ---

  void _handleBlocListener(BuildContext context, AuthState state) {
    if (state.registrationStatus == StudentRegistrationStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.successEntity?.message ??
                "تم إنشاء الحساب بنجاح، يرجى تسجيل الدخول",
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else if (state.registrationStatus == StudentRegistrationStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.registrationFailure?.message ?? "حدث خطأ أثناء التسجيل",
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updatePhoneZone(
    TextEditingController controller,
    Function(CountryModel) onUpdate,
  ) {
    setState(() {
      final code = controller.text;
      try {
        final country = countries.firstWhere(
          (x) => x.countryCallingCode == code,
        );
        onUpdate(country);
      } catch (_) {
        // يمكن إضافة منطق للتعامل مع الإدخال اليدوي غير الموجود
      }
    });
  }

  void _showCountryDialog(TextEditingController controller) {
    showDialog(
      context: context,
      builder: (_) => CountryPickerDialog(
        initialCountry: selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            selectedCountry = country;
            controller.text = country.arabicName;
          });
        },
        isCollingCode: false,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final student = StudentApplicantEntity(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        bio: _bioCtrl.text.isNotEmpty ? _bioCtrl.text : "طالب جديد",
        qualifications: _qualificationCtrl.text,
        memorizationLevel: int.tryParse(_memorizationCtrl.text),
        gender: Gender.fromLabel( _genderCtrl.text),
        birthDate: _birthDateCtrl.text,
        phone: _phoneCtrl.text,
        phoneZone: _phoneZoneCtrl.text.replaceAll('+', ''),
        whatsapp: _whatsAppPhoneCtrl.text,
        whatsappZone: _whatsAppZoneCtrl.text.replaceAll('+', ''),
        country: _countryCtrl.text,
        residence: _residenceCtrl.text,
        // تأكد من إضافة الحقول الأخرى في الـ Entity إذا لزم الأمر
      );

      context.read<AuthBloc>().add(
        SubmitStudentRegistration(studentApplicant: student),
      );
    }
  }
}
