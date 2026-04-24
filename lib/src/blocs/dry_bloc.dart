import 'package:bloc/bloc.dart';
import 'package:dry_bloc/dry_bloc.dart';
import 'package:meta/meta.dart';

/// Function type that determines whether an exception should be treated as
/// fatal
typedef DryBlocIsFatalExceptionHandler = bool Function(Object exception);

/// Function type that determines whether an exception should be treated as
/// fatal.
typedef DryBlocGlobalIsFatalExceptionHandler = bool Function(
  Object exception,
  DryBlocIsFatalExceptionHandler defaultIsFatal,
);

/// {@template dry_bloc.DryBloc}
/// Base BLoC class with built-in state and error handling
/// {@endtemplate}
///
/// - [Event] type of events this BLoC processes
/// - [State] type of state, must extend [DryState<Error>]
/// - [Data] type of successful state data
/// - [Err] type of business errors
abstract class DryBloc<Event, State extends DryState<Err>, Data,
    Err extends Object> extends Bloc<Event, State> {
  /// {@macro dry_bloc.DryBloc}
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
  /// If [Err] is not `Object`, exceptions are considered fatal
  /// unless they are instances of [Err].
  bool defaultIsFatalException(Object exception) {
    if (Err == Object) return true;
    return exception is! Err;
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
  State inFailure(DryException<Err> exc);

  /// Handles events of type [Ev] with the provided [action]
  ///
  /// - [action] async function that returns data
  /// - [transformer] optional event transformer
  /// - [isFatalExceptionOverride] optional exception fatality handler
  /// for this method
  void handle<Ev extends Event>(
    Future<Data> Function(Ev event) action, {
    EventTransformer<Ev>? transformer,
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

  /// Handles an exception and emits the appropriate state, then rethrows the
  /// exception after wrapping it in a corresponding [DryException] subclass,
  /// so you can further handle it properly
  /// (e.g., using `runZonedGuarded`'s `onError` callback),
  /// depending on its type(Fatal, BusinessTyped, BusinessUntyped).
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
    final exc = isFatal
        ? DryException<Err>.fatal(exception)
        : exception is Err && Err != Object
            ? DryException<Err>.businessTyped(exception)
            : DryException<Err>.businessUntyped(exception);

    emit(inFailure(exc));

    throw exc;
  }
}

/// {@template dry_bloc.DrySingleEventBlocBase}
/// Base class for a BLoC that handles a single event type.
///
/// This class automatically sets up the event handler in the constructor
/// and marks the default [add] method as internal.
/// {@endtemplate}
///
/// - [Event] the type of events this BLoC processes
/// - [State] the type of state, must extend [DryState<Err>]
/// - [Data] the type of successful state data
/// - [Err] the type of business errors
sealed class DrySingleEventBlocBase<Event, State extends DryState<Err>, Data,
    Err extends Object> extends DryBloc<Event, State, Data, Err> {
  /// {@macro dry_bloc.DrySingleEventBlocBase}
  DrySingleEventBlocBase(
    super.initialState, {
    required Future<Data> Function(Event event) action,
    EventTransformer<Event>? transformer,
    DryBlocIsFatalExceptionHandler? isFatalExceptionOverride,
  }) {
    handle<Event>(
      action,
      transformer: transformer,
      isFatalExceptionOverride: isFatalExceptionOverride,
    );
  }

  @override
  @internal
  void add(Event event) => super.add(event);
}

/// {@template dry_bloc.DrySingleEventBloc}
/// BLoC that handles a single event type with data.
///
/// This class provides a public [addSingleEvent] method for adding events
/// with data.
/// {@endtemplate}
///
/// - [Event] the type of events this BLoC processes
/// - [State] the type of state, must extend [DryState<Err>]
/// - [Data] the type of successful state data
/// - [Err] the type of business errors
abstract class DrySingleEventBloc<Event, State extends DryState<Err>, Data,
        Err extends Object>
    extends DrySingleEventBlocBase<Event, State, Data, Err> {
  /// {@macro dry_bloc.DrySingleEventBloc}
  DrySingleEventBloc(
    super.initialState, {
    required super.action,
    super.transformer,
    super.isFatalExceptionOverride,
  });

  /// Adds an event for processing.
  ///
  /// - [event] the event to process
  void addSingleEvent(Event event) => add(event);
}

/// {@template dry_bloc.DrySingleVoidEventBloc}
/// BLoC that handles void events (events without data).
///
/// This class provides a public [addSingleEvent] method for adding events
/// without parameters.
/// {@endtemplate}
///
/// - [State] the type of state, must extend [DryState<Err>]
/// - [Data] the type of successful state data
/// - [Err] the type of business errors
abstract class DrySingleVoidEventBloc<State extends DryState<Err>, Data,
    Err extends Object> extends DrySingleEventBlocBase<void, State, Data, Err> {
  /// {@macro dry_bloc.DrySingleVoidEventBloc}
  DrySingleVoidEventBloc(
    super.initialState, {
    required Future<Data> Function() action,
    super.transformer,
    super.isFatalExceptionOverride,
  }) : super(action: (event) => action());

  /// Adds a no-data event for processing.
  void addSingleEvent() => add(null);
}
