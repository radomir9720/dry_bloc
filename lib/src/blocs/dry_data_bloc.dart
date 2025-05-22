import 'package:dry_bloc/dry_bloc.dart';

/// A specialized BLoC that works with [DryDataState]
///
/// This BLoC is designed for features that always have data, even during
/// loading or error states.
///
/// - [Event] type of events this BLoC processes
/// - [Data] type of data maintained across all states
/// - [Error] type of business errors
abstract class DryDataBloc<Event, Data, Error extends Object>
    extends DryBloc<Event, DryDataState<Data, Error>, Data, Error> {
  /// Creates a [DryDataBloc] with the provided initial state
  DryDataBloc(super.initialState);

  @override
  DryDataState<Data, Error> inInitial() => state.inInitial();

  @override
  DryDataState<Data, Error> inLoading() => state.inLoading();

  @override
  DryDataState<Data, Error> inSuccess(Data data) => state.inSuccess(data);

  @override
  DryDataState<Data, Error> inFailure(DryException<Error> exc) =>
      state.inFailure(exc);
}
