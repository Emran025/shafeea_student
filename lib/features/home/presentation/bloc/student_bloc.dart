import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
// import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/plan_for_the_day_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/student_info_entity.dart';
import '../../domain/entities/follow_up_plan_entity.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import '../../domain/usecases/get_plan_for_the_day.dart';
import '../../domain/usecases/get_student_by_id.dart';
import '../../domain/usecases/save_student_plan.dart';
import '../../domain/usecases/upsert_student_usecase.dart';
import '../../domain/usecases/usecase.dart';

part 'student_event.dart';
part 'student_state.dart';

// @injectable
class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudentById _getStudentInfoUC;
  final UpsertStudent _upsertStudentUC;
  final DeleteStudentUseCase _deleteStudentUC;
  final GetPlanForTheDay _getPlanForTheDayUC;
  final SaveStudentPlan _saveStudentPlan;

  StudentBloc({
    required GetStudentById getStudentInfo,
    required UpsertStudent upsertStudent,
    required DeleteStudentUseCase deleteStudent,
    required GetPlanForTheDay getPlanForTheDay,
    required SaveStudentPlan saveStudentPlan,
  }) : _upsertStudentUC = upsertStudent,
       _deleteStudentUC = deleteStudent,
       _getStudentInfoUC = getStudentInfo,
       _getPlanForTheDayUC = getPlanForTheDay,
       _saveStudentPlan = saveStudentPlan,
       super(const StudentState()) {
    on<StudentUpserted>(_onUpsert, transformer: droppable());
    on<StudentDeleted>(_onDelete, transformer: droppable());
    on<StudentDetailsFetched>(_onFetchDetails, transformer: restartable());
    on<PlanForTheDayRequested>(
      _onPlanForTheDayRequested,
      transformer: droppable(),
    );
    on<SaveStudentPlanRequested>(
      _onSaveStudentPlanRequested,
      transformer: droppable(),
    );
  }

  Future<void> _onSaveStudentPlanRequested(
    SaveStudentPlanRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: StudentSubmissionStatus.submitting,
        clearSubmissionFailure: true,
      ),
    );

    final result = await _saveStudentPlan(event.plan);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) {
        emit(state.copyWith(submissionStatus: StudentSubmissionStatus.success));
        // Refresh details and plan for the day to reflect new plan immediately
        add(const StudentDetailsFetched());
        add(const PlanForTheDayRequested());
      },
    );
  }

  Future<void> _onPlanForTheDayRequested(
    PlanForTheDayRequested event,
    Emitter<StudentState> emit,
  ) async {
    emit(
      state.copyWith(
        planForTheDayStatus: PlanForTheDayStatus.loading,
        clearPlanForTheDayFailure: true,
      ),
    );

    final result = await _getPlanForTheDayUC(NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          planForTheDayStatus: PlanForTheDayStatus.failure,
          planForTheDayFailure: failure,
        ),
      ),
      (planForTheDay) => emit(
        state.copyWith(
          planForTheDayStatus: PlanForTheDayStatus.success,
          planForTheDay: planForTheDay,
        ),
      ),
    );
  }

  /// Handles the fetching of a single student's detailed profile.
  Future<void> _onFetchDetails(
    StudentDetailsFetched event,
    Emitter<StudentState> emit,
  ) async {
    // 1. Emit a loading state specifically for the details view.
    //    This does not affect the main list's status.
    emit(
      state.copyWith(
        detailsStatus: StudentInfoStatus.loading,
        clearDetailsFailure: true,
      ),
    );

    // 2. Call the use case to fetch the data.
    final result = await _getStudentInfoUC(NoParams());

    // 3. Fold the result and emit either a success or failure state.
    result.fold(
      (failure) => emit(
        state.copyWith(
          detailsStatus: StudentInfoStatus.failure,
          detailsFailure: failure,
        ),
      ),
      (studentDetails) => emit(
        state.copyWith(
          detailsStatus: StudentInfoStatus.success,
          selectedStudent: studentDetails,
        ),
      ),
    );
  }

  /// Handles the creation or update of a student.
  Future<void> _onUpsert(
    StudentUpserted event,
    Emitter<StudentState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: StudentSubmissionStatus.submitting,
        clearSubmissionFailure: true,
      ),
    );

    final result = await _upsertStudentUC(event.student);

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) {
        // On success, the list will update automatically via the stream.
        // We just need to signal that the submission process is complete.
        emit(state.copyWith(submissionStatus: StudentSubmissionStatus.success));
      },
    );
  }

  /// Handles the deletion of a student.
  Future<void> _onDelete(
    StudentDeleted event,
    Emitter<StudentState> emit,
  ) async {
    emit(state.copyWith(submissionStatus: StudentSubmissionStatus.submitting));

    final result = await _deleteStudentUC(NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          submissionStatus: StudentSubmissionStatus.failure,
          submissionFailure: failure,
        ),
      ),
      (_) => emit(
        state.copyWith(submissionStatus: StudentSubmissionStatus.success),
      ),
    );
  }
}
