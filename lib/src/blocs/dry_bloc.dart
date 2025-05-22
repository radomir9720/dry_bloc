import 'package:bloc/bloc.dart';
import 'package:dry_bloc/dry_bloc.dart';

/// Function type that determines whether an exception should be treated as
/// fatal
typedef DryBlocIsFatalExceptionHandler = bool Function(Object exception);

/// Function type that determines whether an exception should be treated as
/// fatal.
typedef DryBlocGlobalIsFatalExceptionHandler = bool Function(
  Object exception,
  DryBlocIsFatalExceptionHandler defaultIsFatal,
);

/// Base BLoC class with built-in state and error handling
///
/// - [Event] type of events this BLoC processes
/// - [State] type of state, must extend DryState<Error>
/// - [Data] type of successful state data
/// - [Error] type of business errors
abstract class DryBloc<Event, State extends DryState<Error>, Data,
    Error extends Object> extends Bloc<Event, State> {
  /// Creates a BLoC with the initial state
  DryBloc(super.initialState);

  /// Global handler for determining exception fatality.
  ///
  /// As a second argument is passed the default implementation, so that
  /// after implementing some custom logic the default implementation can be
  /// used:
  ///
  /// ```dart
  /// void main() {
  ///
  ///   DryBloc.globalIsFatalException = (
  ///     Object exception,
  ///     DryBlocIsFatalExceptionHandler defaultIsFatal,
  ///   ) {
  ///     // this way, if the exception is UntypedError, it will be threated as a
  ///     // business logic untyped error
  ///     if (exception is UntypedError) return false;
  ///     // Otherwise, the logic will be delegated to the defaultIsFatal.
  ///     return defaultIsFatal(exception);
  ///   };
  /// ```
  static DryBlocGlobalIsFatalExceptionHandler? globalIsFatalException;

  /// The default implementation, that determines whether an
  /// exception should be treated as fatal
  ///
  /// If [Error] is not `Object`, exceptions are considered fatal
  /// unless they are instances of [Error].
  bool defaultIsFatalException(Object exception) {
    if (Error == Object) return true;
    return exception is! Error;
  }

  /// Determines whether an exception should be treated as fatal
  ///
  /// First checks the [globalIsFatalException] handler if set.
  /// If it's not, then the logic is delegated to [defaultIsFatalException].
  bool isFatalException(Object exception) {
    final globalIsFatal = globalIsFatalException;
    if (globalIsFatal != null) {
      return globalIsFatal(exception, defaultIsFatalException);
    }
    return defaultIsFatalException(exception);
  }

  /// Returns the initial state
  State inInitial();

  /// Returns the loading state
  State inLoading();

  /// Returns the success state with [data]
  State inSuccess(Data data);

  /// Returns the failure state with exception [exc]
  State inFailure(DryException<Error> exc);

  /// Handles events of type [Ev] with the provided [action]
  ///
  /// - [action] async function that returns data
  /// - [transformer] optional event transformer
  /// - [isFatalExceptionOverride] optional exception fatality handler
  /// for this method
  void handle<Ev extends Event>(
    Future<Data> Function(Ev event) action, {
    Stream<Ev> Function(Stream<Ev>, Stream<Ev> Function(Ev))? transformer,
    DryBlocIsFatalExceptionHandler? isFatalExceptionOverride,
  }) {
    return on<Ev>(
      (event, emit) async {
        emit(inLoading());

        try {
          emit(inSuccess(await action(event)));
        } on Object catch (e) {
          await handleException(e, isFatalExceptionOverride, emit);
        }
      },
      transformer: transformer,
    );
  }

  /// Handles an exception and emits the appropriate state
  ///
  /// - [exception] caught exception
  /// - [isFatalExceptionOverride] exception fatality handler
  /// - [emit] state emitter
  Future<void> handleException(
    Object exception,
    DryBlocIsFatalExceptionHandler? isFatalExceptionOverride,
    Emitter<State> emit,
  ) async {
    final isFatal = (isFatalExceptionOverride ?? isFatalException)(exception);
    if (isFatal) {
      emit(inFailure(DryException.fatal(exception)));

      // ignore: only_throw_errors
      throw exception;
    }
    if (exception is Error && Error != Object) {
      return emit(inFailure(DryException.businessTyped(exception)));
    }

    emit(inFailure(DryException.businessUntyped(exception)));
  }
}
