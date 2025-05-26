import 'package:dry_bloc/dry_bloc.dart';

/// Extension on [Object] that provides convenient pattern matching
/// for [DryException] types.
extension MaybeWhenDryExceptionExtension on Object {
  /// Pattern matches on [DryException] if this object is an instance of it.
  ///
  /// This method checks if the current object is a [DryException] and if so,
  /// delegates to the appropriate handler based on the exception type.
  /// If the object is not a [DryException], or the appropriate handler
  /// is not provided, the [orElse] handler is called.
  ///
  /// Parameters:
  /// - [orElse]: Required fallback handler called when the object is not a
  /// [DryException] or when a specific handler is not provided for
  /// the exception type.
  /// - [businessTyped]: Optional handler for [DryBusinessTypedException].
  /// Called when a business logic error of the expected type occurs.
  /// - [businessUntyped]: Optional handler for [DryBusinessUntypedException].
  /// Called when a business logic error occurs but doesn't match the expected
  /// type.
  /// - [fatal]: Optional handler for [DryFatalException]. Called when a
  /// fatal/critical error occurs that shouldn't happen during normal
  /// application operation.
  ///
  /// Example:
  /// ```dart
  ///   runZonedGuarded(
  ///     () async {
  ///       runApp(...);
  ///     },
  ///     (error, stack) {
  ///       error.maybeWhenDryException(
  ///         // If yout want to log to the Crashlytics only fatal exceptions
  ///         businessTyped: (error) {},
  ///         businessUntyped: (error) {},
  ///         orElse: (error) =>
  ///             FirebaseCrashlytics.instance.recordError(error, stack),
  ///       );
  ///     },
  /// );
  /// ```
  R maybeWhenDryException<R>({
    required R Function(Object error) orElse,
    R Function(Object error)? businessTyped,
    R Function(Object error)? businessUntyped,
    R Function(Object error)? fatal,
  }) {
    if (this is DryException) {
      return (this as DryException).when(
        fatal: fatal ?? orElse,
        businessTyped: businessTyped ?? orElse,
        businessUntyped: businessUntyped ?? orElse,
      );
    }
    return orElse(this);
  }
}
