import '../../domain/entities/import_export.dart';

String toDisplayString(dynamic anEnum) {
  switch (anEnum) {
    case EntityType.followUpReport:
      return 'بيانات المتابعات';
    case DataExportFormat.csv:
      return 'CSV';
    case DataExportFormat.json:
      return 'JSON';
    case ConflictResolution.skip:
      return 'تجاهل';
    case ConflictResolution.overwrite:
      return 'الكتابة فوق';
    default:
      return anEnum.toString().split('.').last;
  }
}
