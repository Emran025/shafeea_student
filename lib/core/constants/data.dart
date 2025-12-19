import 'package:flutter/material.dart';
import 'package:shafeea/core/models/active_status.dart';
import 'package:shafeea/core/models/gender.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/core/models/tracking_units.dart';
import 'package:shafeea/features/home/domain/entities/student_info_entity.dart';

import '../../features/home/data/models/follow_up_plan_model.dart';
import '../../features/home/data/models/plan_detail_model.dart';
import '../../features/home/data/models/tracking_detail_model.dart';
import '../../features/home/data/models/tracking_model.dart';
import '../../features/home/domain/entities/follow_up_plan_entity.dart';
import '../../features/home/domain/entities/halqa_entity.dart';
import '../../features/home/domain/entities/plan_detail_entity.dart';
import '../../features/home/domain/entities/student_entity.dart';
import '../models/attendance_type.dart';
import '../models/report_frequency.dart';
import 'tracking_unit_detail.dart';

// ملاحظة: ستحتاج إلى استيراد نماذج البيانات الخاصة بك
// import 'package/to/your/models.dart';

// ----------------------------------------------------
// 1. الخطة الدراسية للطالب (FollowUpPlanModel)
// ----------------------------------------------------
final FollowUpPlanModel studentPlan = FollowUpPlanModel(
  planId: "55",
  serverPlanId: "plan_12345",
  frequency: Frequency.daily,
  createdAt: '2025-07-20T10:00:00Z',
  updatedAt: '2025-07-20T10:00:00Z',
  details: [
    PlanDetailModel(
      type: TrackingType.memorization, // يطابق trackingTypeId: 1
      unit: TrackingUnitTyps.page,
      amount: 1,
    ),
    PlanDetailModel(
      type: TrackingType.review, // يطابق trackingTypeId: 2
      unit: TrackingUnitTyps.page,
      amount: 10, // ما يعادل نصف جزء تقريبًا
    ),
    PlanDetailModel(
      type: TrackingType.recitation, // يطابق trackingTypeId: 3
      unit: TrackingUnitTyps.page,
      amount: 10, // ما يعادل حزبًا واحدًا
    ),
  ],
);

// ----------------------------------------------------
// 2. سجلات التتبع اليومية (List<TrackingModel>)
// ----------------------------------------------------
final List<TrackingModel> studentTrackings = [
  // --- اليوم الأول: 21-09-2023 (أداء ضعيف ومتأخر) ---
  TrackingModel(
    id: 1001,
    date: '2025-07-21',
    note: 'بداية أسبوع غير موفقة، كان الطالب مشتتاً.',    
    enrollmentId:0,
    behaviorNote: 3, // (من 5)
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-21T18:00:00Z',
    updatedAt: '2025-07-21T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2001,
        trackingId: 1001, // <-- يجب أن يطابق id سجل التتبع
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[1], // مثال: سورة البقرة
        toTrackingUnitId: trackingUnitDetail[1],
        actualAmount: 0, // لم يحفظ شيئًا
        status: 'completed',
        comment: 'لم يتمكن من الحفظ بسبب الإرهاق.',
        score: 2, // (من 5)
        createdAt: '2025-07-21T18:00:00Z',
        updatedAt: '2025-07-21T18:00:00Z',
        uuid: '0026',
      ),
      TrackingDetailModel(
        id: 2002,
        trackingId: 1001,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[40], // مثال: من صفحة 40
        toTrackingUnitId: trackingUnitDetail[48], // إلى صفحة 48
        actualAmount: 8, // المطلوب 10، أنجز 8 فقط
        status: 'completed',
        comment: 'المراجعة كانت متقطعة وبها أخطاء.',
        score: 3,
        createdAt: '2025-07-21T18:00:00Z',
        updatedAt: '2025-07-21T18:00:00Z',
        uuid: '0001',
      ),
      TrackingDetailModel(
        id: 2003,
        trackingId: 1001,
        trackingTypeId: TrackingType.fromId(3), // recitation
        fromTrackingUnitId: trackingUnitDetail[100],
        toTrackingUnitId: trackingUnitDetail[110],
        actualAmount: 10, // أنجز المطلوب
        status: 'completed',
        comment: 'التلاوة كانت جيدة.',
        score: 4,
        createdAt: '2025-07-21T18:00:00Z',
        updatedAt: '2025-07-21T18:00:00Z',
        uuid: '0002',
      ),
    ],
  ),

  // --- اليوم الثاني: 22-09-2023 (أداء ممتاز وتفوق) ---
  TrackingModel(
    id: 1002,
    date: '2025-07-22',
    note: 'يوم استثنائي، أظهر الطالب تركيزًا عاليًا.',    
    enrollmentId:0,
    behaviorNote: 5,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-22T18:00:00Z',
    updatedAt: '2025-07-22T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2004,
        trackingId: 1002,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[283],
        toTrackingUnitId: trackingUnitDetail[283],
        actualAmount: 2, // المطلوب 1، لكنه أنجز 2 لتعويض الأمس
        status: 'completed',
        comment: 'حفظ متقن للصفحة المقررة وصفحة إضافية.',
        score: 5,
        createdAt: '2025-07-22T18:00:00Z',
        updatedAt: '2025-07-22T18:00:00Z',
        uuid: '0003',
      ),
      TrackingDetailModel(
        id: 2005,
        trackingId: 1002,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[50],
        toTrackingUnitId: trackingUnitDetail[60],
        actualAmount: 11, // تجاوز المطلوب
        status: 'completed',
        comment: 'مراجعة ممتازة وثابتة.',
        score: 5,
        createdAt: '2025-07-22T18:00:00Z',
        updatedAt: '2025-07-22T18:00:00Z',
        uuid: '0004',
      ),
      TrackingDetailModel(
        id: 2006,
        trackingId: 1002,
        trackingTypeId: TrackingType.fromId(3), // recitation
        fromTrackingUnitId: trackingUnitDetail[111],
        toTrackingUnitId: trackingUnitDetail[121],
        actualAmount: 10,
        status: 'completed',
        comment: 'تلاوة خاشعة ومؤثرة.',
        score: 5,
        createdAt: '2025-07-22T18:00:00Z',
        updatedAt: '2025-07-22T18:00:00Z',
        uuid: '0005',
      ),
    ],
  ),

  // --- اليوم الثالث: 23-09-2023 (أداء جيد ومطابق للخطة) ---
  TrackingModel(
    id: 1003,
    attendanceTypeId: AttendanceType.present,
    date: '2025-07-23',
    note: 'أداء مستقر، التزم بالخطة المحددة.',    
    enrollmentId:0,
    behaviorNote: 4,
    createdAt: '2025-07-23T18:00:00Z',
    updatedAt: '2025-07-23T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2007,
        trackingId: 1003,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[284],
        toTrackingUnitId: trackingUnitDetail[284],
        actualAmount: 1, // أنجز المطلوب بالضبط
        status: 'completed',
        comment: 'حفظ جيد.',
        score: 4,
        createdAt: '2025-07-23T18:00:00Z',
        updatedAt: '2025-07-23T18:00:00Z',
        uuid: '0006',
      ),
      TrackingDetailModel(
        id: 2008,
        trackingId: 1003,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[61],
        toTrackingUnitId: trackingUnitDetail[70],
        actualAmount: 10, // أنجز المطلوب بالضبط
        status: 'completed',
        comment: 'مراجعة جيدة.',
        score: 4,
        createdAt: '2025-07-23T18:00:00Z',
        updatedAt: '2025-07-23T18:00:00Z',
        uuid: '0007',
      ),
    ],
  ),

  // ملاحظة: البيانات التالية هي إضافة للبيانات السابقة.
  // The following data is an addition to the previous data.
  TrackingModel(
    id: 1004,
    attendanceTypeId: AttendanceType.present,
    date: '2025-07-24',
    note: 'يوم مستقر، تم الالتزام بالخطة.',    
    enrollmentId:0,
    behaviorNote: 4,
    createdAt: '2025-07-24T18:00:00Z',
    updatedAt: '2025-07-24T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2009,
        trackingId: 1004,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[285],
        toTrackingUnitId: trackingUnitDetail[285],
        actualAmount: 1, // أنجز المطلوب
        status: 'completed',
        comment: 'حفظ جيد.',
        score: 4,
        createdAt: '2025-07-24T18:00:00Z',
        updatedAt: '2025-07-24T18:00:00Z',
        uuid: '0008',
      ),
      TrackingDetailModel(
        id: 2010,
        trackingId: 1004,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[71],
        toTrackingUnitId: trackingUnitDetail[80],
        actualAmount: 10, // أنجز المطلوب
        status: 'completed',
        comment: 'المراجعة تمت بشكل جيد.',
        score: 4,
        createdAt: '2025-07-24T18:00:00Z',
        updatedAt: '2025-07-24T18:00:00Z',
        uuid: '0009',
      ),
    ],
  ),

  // --- اليوم الخامس: 25-07-2025 (تراجع بسيط) ---
  TrackingModel(
    id: 1005,
    attendanceTypeId: AttendanceType.present,
    date: '2025-07-25',
    note: 'كان الطالب متعباً قليلاً.',    
    enrollmentId:0,
    behaviorNote: 3,
    createdAt: '2025-07-25T18:00:00Z',
    updatedAt: '2025-07-25T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2011,
        trackingId: 1005,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[286],
        toTrackingUnitId: trackingUnitDetail[286],
        actualAmount: 1, // أنجز المطلوب
        status: 'completed',
        comment: 'حفظ جيد.',
        score: 4,
        createdAt: '2025-07-25T18:00:00Z',
        updatedAt: '2025-07-25T18:00:00Z',
        uuid: '0010',
      ),
      TrackingDetailModel(
        id: 2012,
        trackingId: 1005,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[81],
        toTrackingUnitId: trackingUnitDetail[88],
        actualAmount: 8, // تقصير بصفحتين
        status: 'completed',
        comment: 'لم يكمل المراجعة المقررة.',
        score: 3,
        createdAt: '2025-07-25T18:00:00Z',
        updatedAt: '2025-07-25T18:00:00Z',
        uuid: '0011',
      ),
      TrackingDetailModel(
        id: 2013,
        trackingId: 1005,
        trackingTypeId: TrackingType.fromId(3), // recitation
        fromTrackingUnitId: trackingUnitDetail[122],
        toTrackingUnitId: trackingUnitDetail[132],
        actualAmount: 10,
        comment: '',
        status: 'completed',
        score: 4,
        createdAt: '2025-07-25T18:00:00Z',
        updatedAt: '2025-07-25T18:00:00Z',
        uuid: '0012',
      ),
    ],
  ),

  // --- اليوم السادس: 26-07-2025 (يوم تعويضي جيد) ---
  TrackingModel(
    id: 1006,

    date: '2025-07-26',
    note: 'تركيز عالٍ ورغبة في تعويض الأمس.',    
    enrollmentId:0,
    behaviorNote: 5,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-26T18:00:00Z',
    updatedAt: '2025-07-26T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2014,
        trackingId: 1006,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[287],
        toTrackingUnitId: trackingUnitDetail[287],
        actualAmount: 1,
        status: 'completed',
        comment: 'حفظ متقن.',
        score: 5,
        createdAt: '2025-07-26T18:00:00Z',
        updatedAt: '2025-07-26T18:00:00Z',
        uuid: '0013',
      ),
      TrackingDetailModel(
        id: 2015,
        trackingId: 1006,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[89],
        toTrackingUnitId: trackingUnitDetail[100],
        actualAmount: 12, // تعويض عن تقصير الأمس وزيادة
        status: 'completed',
        comment: 'راجع المقرر وزيادة لتعويض الأمس.',
        score: 5,
        createdAt: '2025-07-26T18:00:00Z',
        updatedAt: '2025-07-26T18:00:00Z',
        uuid: '0014',
      ),
    ],
  ),

  // --- اليوم السابع: 27-07-2025 (محاكاة يوم غياب) ---
  TrackingModel(
    id: 1007,
    date: '2025-07-27',
    note: 'غياب الطالب لظرف طارئ.',    
    enrollmentId:0,
    behaviorNote: 1, // سلوك منخفض لأنه لم يحضر
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-27T18:00:00Z',
    updatedAt: '2025-07-27T18:00:00Z',
    details: [], // لا يوجد تفاصيل لأنه كان غائبًا
  ),

  // --- اليوم الثامن: 28-07-2025 (عودة بعد الغياب وأداء ضعيف) ---
  TrackingModel(
    id: 1008,

    date: '2025-07-28',
    note: 'العقل ما زال متأثراً بالغياب.',    
    enrollmentId:0,
    behaviorNote: 2,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-28T18:00:00Z',
    updatedAt: '2025-07-28T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2016,
        trackingId: 1008,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[288],
        toTrackingUnitId: trackingUnitDetail[288],
        actualAmount: 0, // لم يحفظ
        status: 'completed',
        comment: 'لم يستطع التركيز في الحفظ.',
        score: 1,
        createdAt: '2025-07-28T18:00:00Z',
        updatedAt: '2025-07-28T18:00:00Z',
        uuid: '0015',
      ),
      TrackingDetailModel(
        id: 2017,
        trackingId: 1008,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[101],
        toTrackingUnitId: trackingUnitDetail[105],
        actualAmount: 5, // تقصير كبير
        status: 'completed',
        comment: 'مراجعة ضعيفة.',
        score: 2,
        createdAt: '2025-07-28T18:00:00Z',
        updatedAt: '2025-07-28T18:00:00Z',
        uuid: '0016',
      ),
    ],
  ),

  // --- اليوم التاسع إلى الثالث عشر (أداء متنوع) ---
  // [ ... تكرار النمط مع تغييرات طفيفة في الأرقام والتعليقات ... ]

  // --- اليوم التاسع: 29-07-2025 (استعادة مستوى) ---
  TrackingModel(
    id: 1009,

    date: '2025-07-29',
    note: 'بدأ يستعيد تركيزه.',    
    enrollmentId:0,
    behaviorNote: 4,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-29T18:00:00Z',
    updatedAt: '2025-07-29T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2018,
        trackingId: 1009,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[288],
        toTrackingUnitId: trackingUnitDetail[288],
        actualAmount: 1, // حفظ مقرر اليوم
        status: 'completed',
        comment: 'تم حفظ مقرر اليوم لتعويض أمس.',
        score: 4,
        createdAt: '2025-07-29T18:00:00Z',
        updatedAt: '2025-07-29T18:00:00Z',
        uuid: '0017',
      ),
      TrackingDetailModel(
        id: 2019,
        trackingId: 1009,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[106],
        toTrackingUnitId: trackingUnitDetail[115],
        actualAmount: 10,
        status: 'completed',
        comment: 'مراجعة جيدة.',
        score: 4,
        createdAt: '2025-07-29T18:00:00Z',
        updatedAt: '2025-07-29T18:00:00Z',
        uuid: '0018',
      ),
    ],
  ),

  // --- اليوم العاشر: 30-07-2025 (أداء ممتاز) ---
  TrackingModel(
    id: 1010,

    date: '2025-07-30',
    note: 'يوم رائع، حماس عالي.',    
    enrollmentId:0,
    behaviorNote: 5,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-30T18:00:00Z',
    updatedAt: '2025-07-30T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2020,
        trackingId: 1010,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[289],
        toTrackingUnitId: trackingUnitDetail[290],
        actualAmount: 2, // تجاوز المطلوب
        status: 'completed',
        comment: 'حفظ صفحتين بإتقان.',
        score: 5,
        createdAt: '2025-07-30T18:00:00Z',
        updatedAt: '2025-07-30T18:00:00Z',
        uuid: '0019',
      ),
    ],
  ),

  // --- اليوم الحادي عشر: 31-07-2025 (تشتت) ---
  TrackingModel(
    id: 1011,

    date: '2025-07-31',
    note: 'عانى من التشتت الذهني.',    
    enrollmentId:0,
    behaviorNote: 3,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-07-31T18:00:00Z',
    updatedAt: '2025-07-31T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2021,
        trackingId: 1011,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[116],
        toTrackingUnitId: trackingUnitDetail[122],
        actualAmount: 7, // تقصير
        status: 'completed',
        comment: 'مراجعة غير مكتملة.',
        score: 2,
        createdAt: '2025-07-31T18:00:00Z',
        updatedAt: '2025-07-31T18:00:00Z',
        uuid: '0020',
      ),
      TrackingDetailModel(
        id: 2022,
        trackingId: 1011,
        trackingTypeId: TrackingType.fromId(3), // recitation
        fromTrackingUnitId: trackingUnitDetail[133],
        toTrackingUnitId: trackingUnitDetail[138],
        actualAmount: 5, // تقصير
        status: 'completed',
        comment: 'تلاوة سريعة.',
        score: 3,
        createdAt: '2025-07-31T18:00:00Z',
        updatedAt: '2025-07-31T18:00:00Z',
        uuid: '0021',
      ),
    ],
  ),

  // --- اليوم الثاني عشر: 01-08-2025 (يوم قياسي) ---
  TrackingModel(
    id: 1012,

    date: '2025-08-01',
    note: 'أداء قياسي لتعويض كل التقصير السابق.',    
    enrollmentId:0,
    behaviorNote: 5,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-08-01T18:00:00Z',
    updatedAt: '2025-08-01T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2023,
        trackingId: 1012,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[291],
        toTrackingUnitId: trackingUnitDetail[291],
        actualAmount: 1,
        comment: '',
        status: 'completed',
        score: 5,
        createdAt: '2025-08-01T18:00:00Z',
        updatedAt: '2025-08-01T18:00:00Z',
        uuid: '0022',
      ),
      TrackingDetailModel(
        id: 2024,
        trackingId: 1012,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[123],
        toTrackingUnitId: trackingUnitDetail[143],
        actualAmount: 20, // ضعف المقرر
        status: 'completed',
        comment: 'مراجعة جزء كامل بإتقان.',
        score: 5,
        createdAt: '2025-08-01T18:00:00Z',
        updatedAt: '2025-08-01T18:00:00Z',
        uuid: '0023',
      ),
    ],
  ),

  // --- اليوم الثالث عشر: 02-08-2025 (ختام مستقر) ---
  TrackingModel(
    id: 1013,

    date: '2025-08-02',
    note: 'عودة إلى المسار الصحيح.',    
    enrollmentId:0,
    behaviorNote: 4,
    attendanceTypeId: AttendanceType.present,
    createdAt: '2025-08-02T18:00:00Z',
    updatedAt: '2025-08-02T18:00:00Z',
    details: [
      TrackingDetailModel(
        id: 2025,
        trackingId: 1013,
        trackingTypeId: TrackingType.fromId(1), // memorization
        fromTrackingUnitId: trackingUnitDetail[292],
        toTrackingUnitId: trackingUnitDetail[292],
        actualAmount: 1,
        comment: '',
        status: 'completed',
        score: 4,
        createdAt: '2025-08-02T18:00:00Z',
        updatedAt: '2025-08-02T18:00:00Z',
        uuid: '0024',
      ),
      TrackingDetailModel(
        id: 2026,
        trackingId: 1013,
        trackingTypeId: TrackingType.fromId(2), // revision
        fromTrackingUnitId: trackingUnitDetail[144],
        toTrackingUnitId: trackingUnitDetail[153],
        actualAmount: 10,
        comment: '',
        status: 'completed',
        score: 4,
        createdAt: '2025-08-02T18:00:00Z',
        updatedAt: '2025-08-02T18:00:00Z',
        uuid: '0025',
      ),
    ],
  ),
];

final StudentInfoEntity fakeStudentInfo = StudentInfoEntity(
  studentDetailEntity: fakeStudent,
  assignedHalaqa: AssignedHalaqasEntity(
    id: "H001",
    halaqaId: "1",
    name: "حلقة النور",
    avatar: "",
    enrolledAt: "2025-07-08 22:21:36",
  ),
  followUpPlan: FollowUpPlanEntity(
    planId: "P1001",
    serverPlanId: "1",
    frequency: Frequency.onceAWeek,
    updatedAt: "2025-06-28T12:00:00Z",
    createdAt: "2025-01-10T09:00:00Z",
    details: [
      PlanDetailEntity(
        type: TrackingType.memorization,
        unit: TrackingUnitTyps.page,
        amount: 5,
      ),
      PlanDetailEntity(
        type: TrackingType.review,
        unit: TrackingUnitTyps.juz,
        amount: 1,
      ),
      PlanDetailEntity(
        type: TrackingType.recitation,
        unit: TrackingUnitTyps.halfHizb,
        amount: 2,
      ),
    ],
  ),
);
final List<StudentInfoEntity> fakeStudentsInfos = [
  fakeStudentInfo,
  fakeStudentInfo,
  fakeStudentInfo,
];

final StudentDetailEntity fakeStudent = StudentDetailEntity(
  id: "1",
  name: "خالد عبد الله",
  avatar: "assets/images/u2.png",
  status: ActiveStatus.active,
  gender: Gender.male,
  birthDate: "2003-05-14",
  email: "khaled.abdullah@email.com",
  phone: "771234567",
  phoneZone: 967,
  whatsAppPhone: "771234567",
  whatsAppZone: 967,
  qualification: "ثانوية عامة",
  experienceYears: 2,
  country: "اليمن",
  residence: "صنعاء القديمة",
  city: "صنعاء",
  availableTime: const TimeOfDay(hour: 16, minute: 0),
  stopReasons: "",
  memorizationLevel: "10",
  bio: "طالب مجتهد يشارك بانتظام في جميع الأنشطة القرآنية.",
  createdAt: "2024-09-01T10:00:00Z",
  updatedAt: "2025-06-28T12:30:00Z",
);

final List<StudentDetailEntity> fakeStudents1 = [
  fakeStudent,
  fakeStudent,
  fakeStudent,
  fakeStudent,
];
