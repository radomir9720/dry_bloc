import 'package:dry_bloc/dry_bloc.dart';

/// A specialized BLoC that works with [DryEmptyState]
///
/// This BLoC is designed for features that don't need to maintain data
/// across state transitions, such as simple operations without return values.
///
/// - [Event] type of events this BLoC processes
/// - [Error] type of business errors
abstract class DryEmptyBloc<Event, Error extends Object>
    extends DryBloc<Event, DryEmptyState<Error>, dynamic, Error> {
  /// Creates a [DryEmptyBloc]
  ///
  /// - [initialState] optional initial state. If not provided, the initial
  /// state will be [DryEmptyState.initial()]
  DryEmptyBloc({DryEmptyState<Error>? initialState})
      : super(initialState ?? DryEmptyState<Error>.initial());

  @override
  DryEmptyState<Error> inInitial() => state.inInitial();

  @override
  DryEmptyState<Error> inLoading() => state.inLoading();

  @override
  DryEmptyState<Error> inSuccess(_) => state.inSuccess();

  @override
  DryEmptyState<Error> inFailure(DryException<Error> exc) =>
      state.inFailure(exc);
}
