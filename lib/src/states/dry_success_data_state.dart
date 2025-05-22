import 'package:dry_bloc/dry_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// State that only contains data in success state
///
/// This state is useful for features that only have data in success state,
/// but not during loading or error states (e.g., a one-time fetch operation).
///
/// [D] represents the type of data available in success state.
/// [E] represents the type of business errors.
@immutable
sealed class DrySuccessDataState<D, E extends Object>
    with EquatableMixin
    implements DryState<E> {
  /// Creates an initial state
  @literal
  const factory DrySuccessDataState.initial() = _InitialState<D, E>;

  /// Creates a loading state
  @literal
  const factory DrySuccessDataState.loading() = _LoadingState<D, E>;

  /// Creates a success state with data
  @literal
  const factory DrySuccessDataState.success(D data) = _SuccessState<D, E>;

  /// Creates a failure state with exception
  @literal
  const factory DrySuccessDataState.failure(DryException<E> exc) =
      _FailureState<D, E>;

  /// Base constructor for success data states
  @literal
  const DrySuccessDataState._();

  /// Whether this state represents a completed operation (success or failure)
  @nonVirtual
  bool get isExecuted => isSuccess || isFailure;

  /// Whether this state is in initial status
  @nonVirtual
  bool get isInitial => this is _InitialState<D, E>;

  /// Whether this state is in loading status
  @nonVirtual
  bool get isLoading => this is _LoadingState<D, E>;

  /// Whether this state is in success status
  @nonVirtual
  bool get isSuccess => this is _SuccessState<D, E>;

  /// Whether this state is in failure status
  @nonVirtual
  bool get isFailure => this is _FailureState<D, E>;

  /// Transitions to initial state
  @nonVirtual
  DrySuccessDataState<D, E> inInitial() => _InitialState<D, E>();

  /// Transitions to loading state
  @nonVirtual
  DrySuccessDataState<D, E> inLoading() => _LoadingState<D, E>();

  /// Transitions to success state with data
  @nonVirtual
  DrySuccessDataState<D, E> inSuccess(D data) => _SuccessState<D, E>(data);

  /// Transitions to failure state with exception
  @nonVirtual
  DrySuccessDataState<D, E> inFailure(DryException<E> exc) =>
      _FailureState<D, E>(exc);

  /// Pattern matches on the state type and calls the appropriate handler
  ///
  /// - [initial] Handler for initial state
  /// - [loading] Handler for loading state
  /// - [success] Handler for success state with data
  /// - [failure] Handler for failure state with exception
  ///
  /// Returns the result of the matched handler
  @nonVirtual
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(D data) success,
    required R Function(DryException<E> exc) failure,
  }) {
    return switch (this) {
      _InitialState() => initial(),
      _LoadingState() => loading(),
      _SuccessState(:final data) => success(data),
      _FailureState(:final exc) => failure(exc),
    };
  }

  /// Pattern matches on the state type with nullable return
  ///
  /// - [initial] Optional handler for initial state
  /// - [loading] Optional handler for loading state
  /// - [success] Optional handler for success state with data
  /// - [failure] Optional handler for failure state with exception
  ///
  /// Returns the result of the matched handler or null
  @nonVirtual
  R? whenOrNull<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(D data)? success,
    R Function(DryException<E> exc)? failure,
  }) {
    return switch (this) {
      _InitialState() => initial?.call(),
      _LoadingState() => loading?.call(),
      _SuccessState(:final data) => success?.call(data),
      _FailureState(:final exc) => failure?.call(exc),
    };
  }

  /// Pattern matches on the state type with fallback
  ///
  /// - [orElse] Default handler if no specific handler matches
  /// - [initial] Optional handler for initial state
  /// - [loading] Optional handler for loading state
  /// - [success] Optional handler for success state with data
  /// - [failure] Optional handler for failure state with exception
  ///
  /// Returns the result of the matched handler or orElse
  @nonVirtual
  R maybeWhen<R>({
    required R Function(D? data) orElse,
    R Function()? initial,
    R Function()? loading,
    R Function(D data)? success,
    R Function(DryException<E> exc)? failure,
  }) {
    return switch (this) {
      _InitialState() => initial?.call() ?? orElse(null),
      _LoadingState() => loading?.call() ?? orElse(null),
      _SuccessState(:final data) => success?.call(data) ?? orElse(data),
      _FailureState(:final exc) => failure?.call(exc) ?? orElse(null),
    };
  }

  /// Creates a copy of this state with optional new data or exception
  ///
  /// - [data] Optional new data for success state
  /// - [exc] Optional new exception for failure state
  ///
  /// Returns a new state with updated fields
  @nonVirtual
  DrySuccessDataState<D, E> copyWith({D? data, DryException<E>? exc}) {
    return when(
      initial: DrySuccessDataState<D, E>.initial,
      loading: DrySuccessDataState<D, E>.loading,
      success: (d) => DrySuccessDataState<D, E>.success(data ?? d),
      failure: (e) => DrySuccessDataState<D, E>.failure(exc ?? e),
    );
  }

  @override
  @internal
  List<Object?> get props => [];
}

@immutable
class _InitialState<P, E extends Object> extends DrySuccessDataState<P, E> {
  @literal
  const _InitialState() : super._();
}

@immutable
class _LoadingState<P, E extends Object> extends DrySuccessDataState<P, E> {
  @literal
  const _LoadingState() : super._();
}

@immutable
class _SuccessState<P, E extends Object> extends DrySuccessDataState<P, E> {
  @literal
  const _SuccessState(this.data) : super._();

  final P data;

  @override
  List<Object?> get props => [data];
}

@immutable
class _FailureState<P, E extends Object> extends DrySuccessDataState<P, E> {
  @literal
  const _FailureState(this.exc) : super._();

  final DryException<E> exc;

  @internal
  @override
  List<Object?> get props => [exc];
}
