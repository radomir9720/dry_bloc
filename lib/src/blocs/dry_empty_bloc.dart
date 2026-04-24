import 'package:dry_bloc/dry_bloc.dart';

/// Mixin, that implements the [DryBloc]'s state methods with [DryEmptyState]
mixin DryEmptyBlocMixin<Event, Err extends Object>
    on DryBloc<Event, DryEmptyState<Err>, void, Err> {
  @override
  DryEmptyState<Err> inInitial() => state.inInitial();

  @override
  DryEmptyState<Err> inLoading() => state.inLoading();

  @override
  DryEmptyState<Err> inSuccess(void data) => state.inSuccess();

  @override
  DryEmptyState<Err> inFailure(DryException<Err> exc) => state.inFailure(exc);
}

/// {@template dry_bloc.DryEmptyBloc}
/// A specialized BLoC that works with [DryEmptyState]
///
/// This BLoC is designed for features that don't need to maintain data
/// across state transitions, such as simple operations without return values.
/// {@endtemplate}
///
/// - [Event] type of events this BLoC processes
/// - [Err] type of business errors
abstract class DryEmptyBloc<Event, Err extends Object>
    extends DryBloc<Event, DryEmptyState<Err>, void, Err>
    with DryEmptyBlocMixin {
  /// {@macro dry_bloc.DryEmptyBloc}
  ///
  /// - [initialState] optional initial state. If not provided, the initial
  /// state will be [DryEmptyState.initial()]
  DryEmptyBloc({DryEmptyState<Err>? initialState})
      : super(initialState ?? DryEmptyState<Err>.initial());
}

/// {@macro dry_bloc.DrySingleEventBloc}
///
/// {@macro dry_bloc.DryEmptyBloc}
///
/// See also:
///  * [DryEmptyBloc]
///  * [DrySingleEventBloc]
abstract class DryEmptySingleEventBloc<Event, Err extends Object>
    extends DrySingleEventBloc<Event, DryEmptyState<Err>, void, Err>
    with DryEmptyBlocMixin {
  /// {@macro dry_bloc.DrySingleEventBloc}
  ///
  /// {@macro dry_bloc.DryEmptyBloc}
  DryEmptySingleEventBloc({
    required super.action,
    DryEmptyState<Err>? initialState,
    super.transformer,
    super.isFatalExceptionOverride,
  }) : super(initialState ?? DryEmptyState<Err>.initial());
}

/// {@macro dry_bloc.DrySingleVoidEventBloc}
///
/// {@macro dry_bloc.DryEmptyBloc}
///
/// See also:
///  * [DryEmptyBloc]
///  * [DrySingleVoidEventBloc]
abstract class DryEmptySingleVoidEventBloc<Err extends Object>
    extends DrySingleVoidEventBloc<DryEmptyState<Err>, void, Err>
    with DryEmptyBlocMixin {
  /// {@macro dry_bloc.DrySingleVoidEventBloc}
  ///
  /// {@macro dry_bloc.DryEmptyBloc}
  DryEmptySingleVoidEventBloc({
    required super.action,
    DryEmptyState<Err>? initialState,
    super.transformer,
    super.isFatalExceptionOverride,
  }) : super(initialState ?? DryEmptyState<Err>.initial());
}
