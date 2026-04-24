import 'package:dry_bloc/dry_bloc.dart';

/// Mixin, that implements the [DryBloc]'s state methods with
/// [DrySuccessDataState]
mixin DrySuccessDataBlocMixin<Event, Data, Err extends Object>
    on DryBloc<Event, DrySuccessDataState<Data, Err>, Data, Err> {
  @override
  DrySuccessDataState<Data, Err> inInitial() => state.inInitial();

  @override
  DrySuccessDataState<Data, Err> inLoading() => state.inLoading();

  @override
  DrySuccessDataState<Data, Err> inSuccess(Data data) =>
      DrySuccessDataState.success(data);

  @override
  DrySuccessDataState<Data, Err> inFailure(DryException<Err> exc) =>
      state.inFailure(exc);
}

/// {@template dry_bloc.DrySuccessDataBloc}
/// A specialized BLoC that works with [DrySuccessDataState]
///
/// This BLoC is designed for features that only have data in success state,
/// but not during loading or error states.
/// {@endtemplate}
///
/// - [Event] - type of events this BLoC processes
/// - [Data] - type of data available in success state
/// - [Err] - type of business errors
abstract class DrySuccessDataBloc<Event, Data, Err extends Object>
    extends DryBloc<Event, DrySuccessDataState<Data, Err>, Data, Err>
    with DrySuccessDataBlocMixin {
  /// {@macro dry_bloc.DrySuccessDataBloc}
  ///
  /// - [initialState] optional initial state. If not provided, the initial
  /// state will be [DrySuccessDataState.initial()]
  DrySuccessDataBloc({DrySuccessDataState<Data, Err>? initialState})
      : super(initialState ?? DrySuccessDataState<Data, Err>.initial());
}

/// {@macro dry_bloc.DrySingleEventBloc}
///
/// {@macro dry_bloc.DrySuccessDataBloc}
///
/// See also:
///  * [DrySuccessDataBloc]
///  * [DrySingleEventBloc]
abstract class DrySuccessDataSingleEventBloc<Event, Data, Err extends Object>
    extends DrySingleEventBloc<Event, DrySuccessDataState<Data, Err>, Data, Err>
    with DrySuccessDataBlocMixin {
  /// {@macro dry_bloc.DrySingleEventBloc}
  ///
  /// {@macro dry_bloc.DrySuccessDataBloc}
  DrySuccessDataSingleEventBloc({
    required super.action,
    DrySuccessDataState<Data, Err>? initialState,
    super.transformer,
    super.isFatalExceptionOverride,
  }) : super(initialState ?? DrySuccessDataState<Data, Err>.initial());
}

/// {@macro dry_bloc.DrySingleVoidEventBloc}
///
/// {@macro dry_bloc.DrySuccessDataBloc}
///
/// See also:
///  * [DrySuccessDataBloc]
///  * [DrySingleVoidEventBloc]
abstract class DrySuccessDataSingleVoidEventBloc<Event, Data,
        Err extends Object>
    extends DrySingleVoidEventBloc<DrySuccessDataState<Data, Err>, Data, Err>
    with DrySuccessDataBlocMixin {
  /// {@macro dry_bloc.DrySingleVoidEventBloc}
  ///
  /// {@macro dry_bloc.DrySuccessDataBloc}
  DrySuccessDataSingleVoidEventBloc({
    required super.action,
    DrySuccessDataState<Data, Err>? initialState,
    super.transformer,
    super.isFatalExceptionOverride,
  }) : super(initialState ?? DrySuccessDataState<Data, Err>.initial());
}
