import 'package:intl/intl.dart' show DateFormat;

/// للعرض في الواجهة (عربي)
String formatDate(DateTime dt) {
  // d    => يوم (1 or 2 digits)
  // MMMM => اسم الشهر كامل
  // y    => السنة
  return DateFormat('d MMMM y', 'ar').format(dt);
}

/// للإرسال إلى الـ API بتنسيق ISO 8601 (yyyy-MM-dd)
String formatDateForApi(DateTime dt) {
  return DateFormat('yyyy-MM-dd').format(dt);
}
