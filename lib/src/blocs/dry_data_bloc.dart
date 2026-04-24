import 'package:dry_bloc/dry_bloc.dart';

/// Mixin, that implements the [DryBloc]'s state methods with [DryDataState]
mixin DryDataBlocMixin<Event, Data, Err extends Object>
    on DryBloc<Event, DryDataState<Data, Err>, Data, Err> {
  @override
  DryDataState<Data, Err> inInitial() => state.inInitial();

  @override
  DryDataState<Data, Err> inLoading() => state.inLoading();

  @override
  DryDataState<Data, Err> inSuccess(Data data) => state.inSuccess(data);

  @override
  DryDataState<Data, Err> inFailure(DryException<Err> exc) =>
      state.inFailure(exc);
}

/// {@template dry_bloc.DryDataBloc}
/// A specialized BLoC that works with [DryDataState]
///
/// This BLoC is designed for features that always have data, even during
/// loading or error states.
/// {@endtemplate}
///
/// - [Event] type of events this BLoC processes
/// - [Data] type of data maintained across all states
/// - [Err] type of business errors
abstract class DryDataBloc<Event, Data, Err extends Object>
    extends DryBloc<Event, DryDataState<Data, Err>, Data, Err>
    with DryDataBlocMixin {
  /// {@macro dry_bloc.DryDataBloc}
  DryDataBloc(super.initialState);
}

/// {@macro dry_bloc.DrySingleEventBloc}
///
/// {@macro dry_bloc.DryDataBloc}
///
/// See also:
///  * [DryDataBloc]
///  * [DrySingleEventBloc]
abstract class DryDataSingleEventBloc<Event, Data, Err extends Object>
    extends DrySingleEventBloc<Event, DryDataState<Data, Err>, Data, Err>
    with DryDataBlocMixin {
  /// {@macro dry_bloc.DrySingleEventBloc}
  ///
  /// {@macro dry_bloc.DryDataBloc}
  DryDataSingleEventBloc(
    super.initialState, {
    required super.action,
    super.transformer,
    super.isFatalExceptionOverride,
  });
}

/// {@macro dry_bloc.DrySingleVoidEventBloc}
///
/// {@macro dry_bloc.DryDataBloc}
///
/// See also:
///  * [DryDataBloc]
///  * [DrySingleVoidEventBloc]
abstract class DryDataSingleVoidEventBloc<Data, Err extends Object>
    extends DrySingleVoidEventBloc<DryDataState<Data, Err>, Data, Err>
    with DryDataBlocMixin {
  /// {@macro dry_bloc.DrySingleVoidEventBloc}
  ///
  /// {@macro dry_bloc.DryDataBloc}
  DryDataSingleVoidEventBloc(
    super.initialState, {
    required super.action,
    super.transformer,
    super.isFatalExceptionOverride,
  });
}
