import 'package:dry_bloc/dry_bloc.dart';

/// A specialized BLoC that works with [DrySuccessDataState]
///
/// This BLoC is designed for features that only have data in success state,
/// but not during loading or error states.
///
/// - [Event] - type of events this BLoC processes
/// - [Data] - type of data available in success state
/// - [Error] - type of business errors
abstract class DrySuccessDataBloc<Event, Data, Error extends Object>
    extends DryBloc<Event, DrySuccessDataState<Data, Error>, Data, Error> {
  /// Creates a [DrySuccessDataBloc]
  ///
  /// - [initialState] optional initial state. If not provided, the initial
  /// state will be [DrySuccessDataState.initial()]
  DrySuccessDataBloc({DrySuccessDataState<Data, Error>? initialState})
      : super(initialState ?? DrySuccessDataState<Data, Error>.initial());

  @override
  DrySuccessDataState<Data, Error> inInitial() => state.inInitial();

  @override
  DrySuccessDataState<Data, Error> inLoading() => state.inLoading();

  @override
  DrySuccessDataState<Data, Error> inSuccess(Data data) =>
      DrySuccessDataState.success(data);

  @override
  DrySuccessDataState<Data, Error> inFailure(DryException<Error> exc) =>
      state.inFailure(exc);
}
