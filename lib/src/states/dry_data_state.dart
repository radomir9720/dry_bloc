import 'package:dry_bloc/dry_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// State that always contains data regardless of loading or error status
///
/// This state is useful for features that always have data, even during loading
/// or error states (e.g., a list that can be refreshed).
///
/// - [D] - type of data maintained across all states
/// - [E] - type of business errors
@immutable
sealed class DryDataState<D, E extends Object>
    with EquatableMixin
    implements DryState<E> {
  @literal
  const DryDataState._(this.data);

  /// Creates an initial state with data
  @literal
  const factory DryDataState.initial(D data) = _InitialState<D, E>;

  /// Creates a loading state with data
  @literal
  const factory DryDataState.loading(D data) = _LoadingState<D, E>;

  /// Creates a success state with data
  @literal
  const factory DryDataState.success(D data) = _SuccessState<D, E>;

  /// Creates a failure state with data and exception
  @literal
  const factory DryDataState.failure(
    D data,
    DryException<E> exc,
  ) = _FailureState<D, E>;

  /// The data maintained across all states
  @nonVirtual
  final D data;

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

  /// Transitions to initial state while preserving data
  @nonVirtual
  DryDataState<D, E> inInitial() => _InitialState<D, E>(data);

  /// Transitions to loading state while preserving data
  @nonVirtual
  DryDataState<D, E> inLoading() => _LoadingState<D, E>(data);

  /// Transitions to success state with optional new data
  @nonVirtual
  DryDataState<D, E> inSuccess([D? data]) =>
      _SuccessState<D, E>(data ?? this.data);

  /// Transitions to failure state with exception while preserving data
  @nonVirtual
  DryDataState<D, E> inFailure(DryException<E> exc) =>
      _FailureState<D, E>(data, exc);

  /// Pattern matches on the state type and calls the appropriate handler.
  /// Returns the result of the handler.
  ///
  /// - [initial] Handler for initial state
  /// - [loading] Handler for loading state
  /// - [success] Handler for success state
  /// - [failure] Handler for failure state
  @nonVirtual
  R when<R>({
    required R Function(D data) initial,
    required R Function(D data) loading,
    required R Function(D data) success,
    required R Function(D data, DryException<E> exc) failure,
  }) {
    return switch (this) {
      _InitialState(:final data) => initial(data),
      _LoadingState(:final data) => loading(data),
      _SuccessState(:final data) => success(data),
      _FailureState(:final data, :final exc) => failure(data, exc),
    };
  }

  /// Pattern matches on the state type with nullable return.
  /// Returns the result of the handler or null if the handler is not provided.
  ///
  /// - [initial] Optional handler for initial state
  /// - [loading] Optional handler for loading state
  /// - [success] Optional handler for success state
  /// - [failure] Optional handler for failure state
  @nonVirtual
  R? whenOrNull<R>({
    R Function(D data)? initial,
    R Function(D data)? loading,
    R Function(D data)? success,
    R Function(D data, DryException<E> exc)? failure,
  }) {
    return switch (this) {
      _InitialState(:final data) => initial?.call(data),
      _LoadingState(:final data) => loading?.call(data),
      _SuccessState(:final data) => success?.call(data),
      _FailureState(:final data, :final exc) => failure?.call(data, exc),
    };
  }

  /// Pattern matches on the state type with fallback.
  /// Returns the result of the handler or the fallback if the handler is
  /// not provided.
  ///
  /// - [orElse] Default handler if no specific handler matches
  /// - [initial] Optional handler for initial state
  /// - [loading] Optional handler for loading state
  /// - [success] Optional handler for success state
  /// - [failure] Optional handler for failure state
  @nonVirtual
  R maybeWhen<R>({
    required R Function(D data) orElse,
    R Function(D data)? initial,
    R Function(D data)? loading,
    R Function(D data)? success,
    R Function(D data, DryException<E> exc)? failure,
  }) {
    return switch (this) {
      _InitialState(:final data) => initial?.call(data) ?? orElse(data),
      _LoadingState(:final data) => loading?.call(data) ?? orElse(data),
      _SuccessState(:final data) => success?.call(data) ?? orElse(data),
      _FailureState(:final data, :final exc) =>
        failure?.call(data, exc) ?? orElse(data),
    };
  }

  /// Creates a copy of this state with optional new data or exception.
  /// Returns a new state with the same type as the current state.
  ///
  /// - [data] Optional new data
  /// - [exc] Optional new exception for failure state
  @nonVirtual
  DryDataState<D, E> copyWith({
    D? data,
    DryException<E>? exc,
  }) {
    return when(
      initial: (d) => DryDataState<D, E>.initial(data ?? d),
      loading: (d) => DryDataState<D, E>.loading(data ?? d),
      success: (d) => DryDataState<D, E>.success(data ?? d),
      failure: (d, e) => DryDataState<D, E>.failure(
        data ?? d,
        exc ?? e,
      ),
    );
  }

  @override
  @internal
  List<Object?> get props => [data];
}

@immutable
class _InitialState<D, E extends Object> extends DryDataState<D, E> {
  @literal
  const _InitialState(super.data) : super._();
}

@immutable
class _LoadingState<D, E extends Object> extends DryDataState<D, E> {
  @literal
  const _LoadingState(super.data) : super._();
}

@immutable
class _SuccessState<D, E extends Object> extends DryDataState<D, E> {
  @literal
  const _SuccessState(super.data) : super._();
}

@immutable
class _FailureState<D, E extends Object> extends DryDataState<D, E> {
  @literal
  const _FailureState(
    super.data,
    this.exc,
  ) : super._();

  final DryException<E> exc;

  @internal
  @override
  List<Object?> get props => [...super.props, exc];
}
