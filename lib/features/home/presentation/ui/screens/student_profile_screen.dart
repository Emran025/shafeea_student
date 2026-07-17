import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/date_utils_helper.dart';
import '../../../../../shared/themes/app_theme.dart';
import '../../../../../core/models/active_status.dart';
import '../widgets/study_halaqa_card.dart';

import '../../../../../shared/widgets/avatar.dart';

import '../../../../../config/di/injection.dart';
import '../../../domain/entities/student_entity.dart';
import '../../bloc/student_bloc.dart';
import '../widgets/study_plan_card.dart';
import 'add_student_plan.dart';
import 'package:uuid/uuid.dart';
import 'package:shafeea/core/models/report_frequency.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/core/models/tracking_units.dart';
import '../../../domain/entities/follow_up_plan_entity.dart';
import '../../../domain/entities/plan_detail_entity.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {

  @override
  void initState() {
    super.initState();
  }

  void _submitForms(StudentsPlanForm planForm, String currentPlanId) {
    if (planForm.formKey.currentState?.validate() ?? false) {
      planForm.formKey.currentState?.save();

      final freq = Frequency.values.firstWhere(
        (f) => f.labelAr == planForm.studyPlanType.text,
        orElse: () => Frequency.daily,
      );

      final details = TrackingType.values.map((type) {
        final unitText = planForm.unitTypeControllers[type]?.text ?? 'صفحة';
        final qtyText = planForm.quantityControllers[type]?.text ?? '0';
        final qty = int.tryParse(qtyText) ?? 0;
        final unit = TrackingUnitTyps.values.firstWhere(
          (u) => u.labelAr == unitText,
          orElse: () => TrackingUnitTyps.page,
        );

        return PlanDetailEntity(type: type, unit: unit, amount: qty);
      }).toList();

      final updatedPlan = FollowUpPlanEntity(
        planId: currentPlanId == '0' || currentPlanId.isEmpty ? const Uuid().v4() : currentPlanId,
        serverPlanId: currentPlanId == '0' || currentPlanId.isEmpty ? '0' : currentPlanId,
        frequency: freq,
        details: details,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      context.read<StudentBloc>().add(SaveStudentPlanRequested(updatedPlan));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // الـ BLoC الخاص بالشاشة مسؤول فقط عن بيانات الشاشة
    return BlocProvider(
      create: (context) => sl<StudentBloc>()..add(StudentDetailsFetched()),
      child: Scaffold(
        // backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: Text("الملف الشخصي"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<StudentBloc, StudentState>(
          builder: (context, state) {
            if (state.detailsStatus == StudentInfoStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.detailsStatus == StudentInfoStatus.success) {
              return _buildSuccessfulUI(context, state);
            } else {
              return const Center(child: Text("فشل تحميل التفاصيل"));
            }
          },
        ),
      ),
    );
  }

  Widget _buildSuccessfulUI(BuildContext screenContext, StudentState status) {
    // When success, the data will be in `state.selectedStudent`.
    // Another BlocBuilder can be used to display the actual data.
    final student = status.selectedStudent!.studentDetailEntity;
    final plan = status.selectedStudent!.followUpPlan;
    final halaqa = status.selectedStudent!.assignedHalaqa;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            if (student.status != ActiveStatus.active)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'حسابك قيد المراجعة. تم تفعيل الوضع التجريبي لتتمكن من ضبط خطة حفظك وقراءة الورد اليومي.',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.lightCream87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildHeader(context, student),
            SizedBox(height: 24),
            _buildInfoRow("البريد", student.email),
            Row(
              children: [
                Expanded(child: _buildInfoRow("رقم الهاتف", student.phone)),
                SizedBox(width: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: _buildInfoRow(
                    "",
                    "${status.selectedStudent!.studentDetailEntity.phoneZone}",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    "رقم الواتس",
                    status.selectedStudent!.studentDetailEntity.whatsAppPhone,
                  ),
                ),
                SizedBox(width: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: _buildInfoRow(
                    "",
                    "${status.selectedStudent!.studentDetailEntity.whatsAppZone}",
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    "الجنس",
                    status.selectedStudent!.studentDetailEntity.gender.labelAr,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    "الجنسية",
                    status.selectedStudent!.studentDetailEntity.country,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    "بلد الإقامة",
                    status.selectedStudent!.studentDetailEntity.country,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    "المدينة",
                    status.selectedStudent!.studentDetailEntity.city,
                  ),
                ),
              ],
            ),
            _buildInfoRow(
              "المرحلة التعليمية",
              status.selectedStudent!.studentDetailEntity.qualification,
            ),
            Row(
              children: [
                GestureDetector(
                  // onTap: () => _showStudentReports(),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.accent70,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_note,
                          color: AppColors.lightCream70,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "تعديل البيانات",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightCream87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Divider(height: 2, color: AppColors.accent70)),
              ],
            ),

            titles("حلقة الطالب"),
            SizedBox(height: 12),
            StudyHalaqaCard(
              onPress: () => _showAddStudentPlan(plan),
              assignedHalaqasEntity: halaqa,
            ),

            titles("خطة التقدم"),
            SizedBox(height: 12),
            StudyPlanCard(
              onPress: () => _showAddStudentPlan(plan),
              planType: plan.frequency.labelAr,
              planDetailList: plan.details,
            ),

            titles("مؤشرات الأداء"),
            SingleChildScrollView(
              child: SegmentedButton<String>(
                segments: ["التقدم", "الجودة", "الأداء"]
                    .map(
                      (item) => ButtonSegment<String>(
                        value: item,
                        label: Text(
                          item,
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                      ),
                    )
                    .toList(growable: false),
                selected: {''},
                onSelectionChanged: (newSel) {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showStudentReports(BuildContext screenContext, String studentName) {
  //   showDialog(
  //     context: screenContext,
  //     builder: (_) {
  //       return ShowStudentReportsDialog(studentName: studentName);
  //     },
  //   );
  // }

  Widget titles(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.lightCream70
                : AppColors.mediumDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddStudentPlan(FollowUpPlanEntity plan) {
    final planForm = StudentsPlanForm(initialPlan: plan);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.black45,
              insetPadding: const EdgeInsets.all(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent12,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent70, width: 0.7),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add, color: AppColors.lightCream),
                            const SizedBox(width: 8),
                            Text(
                              "اضافة خطة دراسية",
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightCream,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 2, color: AppColors.accent70),
                        const SizedBox(height: 16),

                        planForm,

                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppColors.accent70),
                                ),
                                child: Text(
                                  "الغاء",
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
                                  _submitForms(planForm, plan.planId);
                                },
                                child: Text(
                                  "حفظ",
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StudentDetailEntity student) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.lightCream.withOpacity(0.1)
            : AppColors.mediumDark70,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightCream38),
      ),
      child: Row(
        children: [
          Avatar(gender: student.gender, pic: student.avatar),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightCream,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: student.status == ActiveStatus.active
                        ? AppColors.success.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    student.status.labelAr,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.lightCream,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mediumDark87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${DateUtilsHelper.calculateAge(student.birthDate)}  عام",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppColors.lightCream,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: student.status == ActiveStatus.active
                      ? AppColors.success.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "25  جزءًا",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppColors.lightCream,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.lightCream12
            : AppColors.mediumDark87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(color: AppColors.lightCream70)),
          Text(value, style: GoogleFonts.cairo(color: AppColors.lightCream)),
        ],
      ),
    );
  }
}
