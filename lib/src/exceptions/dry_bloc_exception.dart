import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Base exception class for BLoC errors with typed error handling
///
/// Provides a structured way to handle different types of errors in BLoCs
/// with support for both business and fatal errors.
///
/// - [E] - type of business errors
sealed class DryException<E extends Object>
    with EquatableMixin
    implements Exception {
  const DryException({
    this.businessTypedError,
    this.businessUntypedError,
    this.fatalError,
  });

  /// Creates a fatal exception that represents system or unexpected errors
  const factory DryException.fatal(Object fatalError) = DryFatalException<E>;

  /// Creates a business exception with a typed error
  const factory DryException.businessTyped(E businessTypedError) =
      DryBusinessTypedException<E>;

  /// Creates a business exception with an untyped error
  const factory DryException.businessUntyped(Object businessUntypedError) =
      DryBusinessUntypedException<E>;

  /// The typed business error if available
  final E? businessTypedError;

  /// The untyped business error if available
  final Object? businessUntypedError;

  /// The fatal error if available
  final Object? fatalError;

  /// Whether this exception represents a fatal error
  bool get isFatal => this is DryFatalException;

  /// Whether this exception represents a business error
  bool get isBusiness => this is DryBusinessException<E>;

  /// Whether this exception represents a typed business error
  bool get isBusinessTyped => this is DryBusinessTypedException<E>;

  /// Whether this exception represents an untyped business error
  bool get isBusinessUntyped => this is DryBusinessUntypedException<E>;

  /// Pattern matches on the exception type and calls the appropriate handler.
  ///
  /// - [fatal] Handler for fatal exceptions
  /// - [businessTyped] Handler for typed business exceptions
  /// - [businessUntyped] Handler for untyped business exceptions
  ///
  /// Returns the result of the matched handler
  @nonVirtual
  R when<R>({
    required R Function(Object error) fatal,
    required R Function(E error) businessTyped,
    required R Function(Object error) businessUntyped,
  }) {
    return switch (this) {
      DryFatalException(:final fatalError) => fatal(fatalError),
      DryBusinessTypedException(:final businessTypedError) =>
        businessTyped(businessTypedError),
      DryBusinessUntypedException(:final businessUntypedError) =>
        businessUntyped(businessUntypedError),
    };
  }

  /// Pattern matches on the exception type with nullable return.
  /// Returns the result of the handler or null if the handler is not provided.
  ///
  /// - [fatal] Optional handler for fatal exceptions
  /// - [businessTyped] Optional handler for typed business exceptions
  /// - [businessUntyped] Optional handler for untyped business exceptions
  @nonVirtual
  R? whenOrNull<R>({
    R Function(Object error)? fatal,
    R Function(E error)? businessTyped,
    R Function(Object error)? businessUntyped,
  }) {
    return switch (this) {
      DryFatalException(:final fatalError) => fatal?.call(fatalError),
      DryBusinessTypedException(:final businessTypedError) =>
        businessTyped?.call(businessTypedError),
      DryBusinessUntypedException(:final businessUntypedError) =>
        businessUntyped?.call(businessUntypedError),
    };
  }

  /// Pattern matches on the exception type with fallback.
  ///
  /// - [orElse] Default handler if no specific handler matches
  /// - [fatal] Optional handler for fatal exceptions
  /// - [businessTyped] Optional handler for typed business exceptions
  /// - [businessUntyped] Optional handler for untyped business exceptions
  ///
  /// Returns the result of the matched handler or [orElse].
  @nonVirtual
  R maybeWhen<R>({
    required R Function(Object error) orElse,
    R Function(Object error)? fatal,
    R Function(E error)? businessTyped,
    R Function(Object error)? businessUntyped,
  }) {
    return switch (this) {
      DryFatalException(:final fatalError) =>
        fatal?.call(fatalError) ?? orElse(fatalError),
      DryBusinessTypedException(:final businessTypedError) =>
        businessTyped?.call(businessTypedError) ?? orElse(businessTypedError),
      DryBusinessUntypedException(:final businessUntypedError) =>
        businessUntyped?.call(businessUntypedError) ??
            orElse(businessUntypedError),
    };
  }

  @internal
  @override
  bool? get stringify => true;
}

/// Exception representing a fatal error
///
/// Used for system errors, crashes, or unexpected exceptions
class DryFatalException<E extends Object> extends DryException<E> {
  /// Creates a fatal exception with the provided error
  const DryFatalException(this.fatalError);

  /// The fatal error
  @override
  final Object fatalError;

  @internal
  @override
  List<Object?> get props => [fatalError];
}

/// Base class for business exceptions
///
/// Represents errors that are expected and can be handled by the application
sealed class DryBusinessException<E extends Object> extends DryException<E> {
  /// Creates a business exception with optional error details
  const DryBusinessException({
    super.businessTypedError,
    super.businessUntypedError,
  });
}

/// Exception representing a typed business error
///
/// Used for domain-specific errors that match the generic type [E]
class DryBusinessTypedException<E extends Object>
    extends DryBusinessException<E> {
  /// Creates a typed business exception with the provided error
  const DryBusinessTypedException(this.businessTypedError);

  /// The typed business error
  @override
  final E businessTypedError;

  @internal
  @override
  List<Object?> get props => [businessTypedError];
}

/// Exception representing an untyped business error
///
/// Used for business errors that don't match the generic type [E]
class DryBusinessUntypedException<E extends Object>
    extends DryBusinessException<E> {
  /// Creates an untyped business exception with the provided error
  const DryBusinessUntypedException(this.businessUntypedError);

  /// The untyped business error
  @override
  final Object businessUntypedError;

  @internal
  @override
  List<Object?> get props => [businessUntypedError];
}
