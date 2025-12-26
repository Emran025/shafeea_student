part of 'tracking_session_bloc.dart';

abstract class TrackingSessionEvent extends Equatable {
  const TrackingSessionEvent();
  @override
  List<Object> get props => [];
}

// --- Session Lifecycle Events ---

/// Dispatched when the screen is first loaded to fetch or create initial session data.
class SessionStarted extends TrackingSessionEvent {
  const SessionStarted();
  @override
  List<Object> get props => [];
}

/// Dispatched when the user taps on an icon in the side navigation bar (Memorize, Review, etc.).
class TaskTypeChanged extends TrackingSessionEvent {
  final TrackingType newType;
  const TaskTypeChanged({required this.newType});
  @override
  List<Object> get props => [newType];
}


/// Dispatched when the user taps the end-of-ayah symbol to mark the recitation range.
class RecitationRangeEnded extends TrackingSessionEvent {
  final int pageNumber;
  final int ayah;
  const RecitationRangeEnded({required this.pageNumber, required this.ayah});
  @override
  List<Object> get props => [pageNumber, ayah];
}

// lib/features/daily_tracking/presentation/bloc/tracking_session_event.dart

// NEW: Event to fetch the historical mistakes for a specific type.
class HistoricalMistakesRequested extends TrackingSessionEvent {
    final int? fromPage;
  final int? toPage;

  const HistoricalMistakesRequested({ this.fromPage , this.toPage});

  @override
  List<Object> get props => [fromPage ??0 , toPage ?? 0];
}



/// Dispatched when the user navigates to a student's profile screen
/// to fetch their detailed information.
final class FollowUpReportFetched extends TrackingSessionEvent {
 
  const FollowUpReportFetched();

  @override
  List<Object> get props => [];
}

// --- Mistake Interaction Events ---

/// Dispatched when the user taps on a word in the Quran text to mark/unmark a mistake.
class WordTappedForMistake extends TrackingSessionEvent {
  final int ayahId;
  final int wordIndex;
  final MistakeType newMistakeType;

  const WordTappedForMistake({required this.ayahId, required this.wordIndex ,required this.newMistakeType,});
  @override
  List<Object> get props => [ayahId, wordIndex,newMistakeType];
}

/// Dispatched from the Task Report Dialog when a teacher categorizes a mistake.
class MistakeCategorized extends TrackingSessionEvent {
  final String mistakeId; // The unique ID of the mistake to be updated.
  final MistakeType newMistakeType;
  const MistakeCategorized({
    required this.mistakeId,
    required this.newMistakeType,
  });
  @override
  List<Object> get props => [mistakeId, newMistakeType];
}
