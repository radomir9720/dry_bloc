import 'package:dry_bloc/dry_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// State without data for operations that don't return values
///
/// This state is useful for features that don't need to maintain data
/// across state transitions, such as simple operations without return values.
///
/// [E] represents the type of business errors.
@immutable
sealed class DryEmptyState<E extends Object>
    with EquatableMixin
    implements DryState<E> {
  /// Base constructor for empty states
  @literal
  const DryEmptyState._();

  /// Creates an initial state
  @literal
  const factory DryEmptyState.initial() = _InitialState<E>;

  /// Creates a loading state
  @literal
  const factory DryEmptyState.loading() = _LoadingState<E>;

  /// Creates a success state
  @literal
  const factory DryEmptyState.success() = _SuccessState<E>;

  /// Creates a failure state with exception
  @literal
  const factory DryEmptyState.failure(DryException<E> exc) = _FailureState<E>;

  /// Whether this state represents a completed operation (success or failure)
  @nonVirtual
  bool get isExecuted => isSuccess || isFailure;

  /// Whether this state is in initial status
  @nonVirtual
  bool get isInitial => this is _InitialState<E>;

  /// Whether this state is in loading status
  @nonVirtual
  bool get isLoading => this is _LoadingState<E>;

  /// Whether this state is in success status
  @nonVirtual
  bool get isSuccess => this is _SuccessState<E>;

  /// Whether this state is in failure status
  @nonVirtual
  bool get isFailure => this is _FailureState<E>;

  /// Transitions to initial state
  @nonVirtual
  DryEmptyState<E> inInitial() => _InitialState<E>();

  /// Transitions to loading state
  @nonVirtual
  DryEmptyState<E> inLoading() => _LoadingState<E>();

  /// Transitions to success state
  @nonVirtual
  DryEmptyState<E> inSuccess() => _SuccessState<E>();

  /// Transitions to failure state with exception
  @nonVirtual
  DryEmptyState<E> inFailure(DryException<E> exc) => _FailureState<E>(exc);

  /// Pattern matches on the state type and calls the appropriate handler
  ///
  /// - [initial] Handler for initial state
  /// - [loading] Handler for loading state
  /// - [success] Handler for success state
  /// - [failure] Handler for failure state
  ///
  /// Returns the result of the matched handler
  @nonVirtual
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function() success,
    required R Function(DryException<E> exc) failure,
  }) {
    return switch (this) {
      _InitialState() => initial(),
      _LoadingState() => loading(),
      _SuccessState() => success(),
      _FailureState(:final exc) => failure.call(exc)
    };
  }

  /// Pattern matches on the state type with nullable return
  ///
  /// - [initial] Optional handler for initial state
  /// - [loading] Optional handler for loading state
  /// - [success] Optional handler for success state
  /// - [failure] Optional handler for failure state
  ///
  /// Returns the result of the matched handler or null
  @nonVirtual
  R? whenOrNull<R>({
    R Function()? initial,
    R Function()? loading,
    R Function()? success,
    R Function(DryException<E> exc)? failure,
  }) {
    return switch (this) {
      _InitialState() => initial?.call(),
      _LoadingState() => loading?.call(),
      _SuccessState() => success?.call(),
      _FailureState(:final exc) => failure?.call(exc),
    };
  }

  /// Pattern matches on the state type with fallback
  ///
  /// - [orElse] Default handler if no specific handler matches
  /// - [initial] Optional handler for initial state
  /// - [loading] Optional handler for loading state
  /// - [success] Optional handler for success state
  /// - [failure] Optional handler for failure state
  ///
  /// Returns the result of the matched handler or orElse
  @nonVirtual
  R maybeWhen<R>({
    required R Function() orElse,
    R Function()? initial,
    R Function()? loading,
    R Function()? success,
    R Function(DryException<E> exc)? failure,
  }) {
    return switch (this) {
      _InitialState() => initial?.call() ?? orElse(),
      _LoadingState() => loading?.call() ?? orElse(),
      _SuccessState() => success?.call() ?? orElse(),
      _FailureState(:final exc) => failure?.call(exc) ?? orElse(),
    };
  }

  /// Creates a copy of this state with optional new exception
  ///
  /// - [exc] Optional new exception for failure state
  ///
  /// Returns a new state with updated fields
  @nonVirtual
  DryEmptyState<E> copyWith(DryException<E>? exc) {
    return when(
      initial: DryEmptyState<E>.initial,
      loading: DryEmptyState<E>.loading,
      success: DryEmptyState<E>.success,
      failure: (e) => DryEmptyState<E>.failure(exc ?? e),
    );
  }

  @override
  @internal
  List<Object?> get props => [];
}

@immutable
class _InitialState<E extends Object> extends DryEmptyState<E> {
  @literal
  const _InitialState() : super._();
}

@immutable
class _LoadingState<E extends Object> extends DryEmptyState<E> {
  @literal
  const _LoadingState() : super._();
}

@immutable
class _SuccessState<E extends Object> extends DryEmptyState<E> {
  @literal
  const _SuccessState() : super._();
}

@immutable
class _FailureState<E extends Object> extends DryEmptyState<E> {
  @literal
  const _FailureState(this.exc) : super._();

  final DryException<E> exc;

  @internal
  @override
  List<Object?> get props => [exc];
}
