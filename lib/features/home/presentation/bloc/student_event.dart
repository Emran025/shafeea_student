part of 'student_bloc.dart';

sealed class StudentEvent extends Equatable {
  const StudentEvent();
  @override
  List<Object> get props => [];
}



/// Dispatched by the user via a pull-to-refresh gesture to force a sync.
final class StudentsRefreshed extends StudentEvent {
  const StudentsRefreshed();
}

/// Dispatched when the user scrolls to the end of the list to load more data.
final class MoreStudentsLoaded extends StudentEvent {
  const MoreStudentsLoaded();
}

/// Dispatched when the user performs an action to add or update a student.
final class StudentUpserted extends StudentEvent {
  final StudentDetailEntity student;
  const StudentUpserted(this.student);
  @override
  List<Object> get props => [student];
}




/// Dispatched when the user navigates to a student's profile screen
/// to fetch their detailed information.
final class StudentDetailsFetched extends StudentEvent {
  
  const StudentDetailsFetched();

  @override
  List<Object> get props => [];
}

/// Dispatched when the user confirms the deletion of a student.
final class StudentDeleted extends StudentEvent {
  final String studentId;
  const StudentDeleted(this.studentId);
  @override
  List<Object> get props => [studentId];
}

final class PlanForTheDayRequested extends StudentEvent {
  const PlanForTheDayRequested();
}
