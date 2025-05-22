// ignore_for_file: prefer_const_constructors
import 'package:bloc_test/bloc_test.dart';
import 'package:dry_bloc/dry_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

enum _Event {
  success,
  // The difference between error and exception is that error is thrown by us.
  // Errors are part of normal functioning of our program. For example,
  // it is completely normal when a user is not authenticated, and we are
  // throwing a correspondig error. On the other hand, exceptions
  // are unexpected. For example, a type mismatch, that didn't let us to parse
  // data at runtime
  throwBusinessTyped,
  throwBusinessUntyped,
  throwFatal,
}

class _TypedError with EquatableMixin implements Exception {
  @override
  List<Object?> get props => [];
}

class _UntypedError with EquatableMixin implements Exception {
  @override
  List<Object?> get props => [];
}

class _FatalException with EquatableMixin implements Exception {
  @override
  List<Object?> get props => [];
}

// ignore: one_member_abstracts
abstract class _PseudoRepository {
  const _PseudoRepository();
  Future<int> doSomething(_Event event);
}

class _PseudoRepositoryMock extends Mock implements _PseudoRepository {}

typedef _DryDataState = DryDataState<int, _TypedError>;

mixin _OverrideIsFatalExceptionMixin<Event, State extends DryState<E>, Data,
    E extends Object> on DryBloc<Event, State, Data, E> {
  @override
  bool isFatalException(Object exception) {
    // this way, if the exception is _UntypedError, it will be threated as a
    // business logic untyped error
    if (exception is _UntypedError) return false;
    // Otherwise, the logic will be delegated to the super method.
    // _TypedError wiil be threated as BusinessTyped error, because it is
    // passed to generic type, i. e. we expect this kind of error, i. e. it is a
    // business logic exception.
    //
    // Other exception will be threated as fatal.
    return super.isFatalException(exception);
  }
}

class _DryDataBloc extends DryDataBloc<_Event, int, _TypedError>
    with _OverrideIsFatalExceptionMixin {
  _DryDataBloc(
    super.initialState, {
    required this.repository,
  }) {
    handle<_Event>(repository.doSomething);
  }

  final _PseudoRepository repository;
}

typedef _DryEmptyState = DryEmptyState<_TypedError>;

class _DryEmptyBloc extends DryEmptyBloc<_Event, _TypedError>
    with
        _OverrideIsFatalExceptionMixin<_Event, _DryEmptyState, dynamic,
            _TypedError> {
  _DryEmptyBloc({required this.repository, super.initialState}) {
    handle<_Event>(repository.doSomething);
  }
  final _PseudoRepository repository;
}

typedef _DrySuccessDataState = DrySuccessDataState<int, _TypedError>;

class _DrySuccessDataBloc extends DrySuccessDataBloc<_Event, int, _TypedError>
    with _OverrideIsFatalExceptionMixin {
  _DrySuccessDataBloc({required this.repository, super.initialState}) {
    handle<_Event>(repository.doSomething);
  }

  final _PseudoRepository repository;
}

void main() {
  group('DryBloc', () {
    final repo = _PseudoRepositoryMock();

    setUpAll(
      () {
        registerFallbackValue(_Event.success);
      },
    );

    setUp(() {
      when(() => repo.doSomething(any())).thenAnswer(
        (invocation) async {
          final event = invocation.positionalArguments[0] as _Event;
          if (event == _Event.success) return 2;
          if (event == _Event.throwBusinessTyped) throw _TypedError();
          if (event == _Event.throwBusinessUntyped) throw _UntypedError();
          // fatal
          throw _FatalException();
        },
      );
    });

    tearDown(() {
      reset(repo);
    });

    group('DryDataBloc', () {
      _DryDataBloc blocInitializer() => _DryDataBloc(
            const DryDataState.initial(1),
            repository: repo,
          );

      blocTest<_DryDataBloc, _DryDataState>(
        'correct initial state',
        build: blocInitializer,
        verify: (bloc) =>
            expect(bloc.state, equals(const _DryDataState.initial(1))),
      );

      blocTest<_DryDataBloc, _DryDataState>(
        'Emits loading, then success',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.success),
        expect: () => [
          const _DryDataState.loading(1),
          const _DryDataState.success(2),
        ],
        verify: (bloc) {
          verify(() => bloc.repository.doSomething(_Event.success)).called(1);
        },
      );

      blocTest<_DryDataBloc, _DryDataState>(
        'Emits loading, then failure with business typed error',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwBusinessTyped),
        expect: () => [
          const _DryDataState.loading(1),
          _DryDataState.failure(
            1,
            DryException<_TypedError>.businessTyped(_TypedError()),
          ),
        ],
      );

      blocTest<_DryDataBloc, _DryDataState>(
        'Emits loading, then failure with business untyped error',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwBusinessUntyped),
        expect: () => [
          const _DryDataState.loading(1),
          _DryDataState.failure(
            1,
            DryBusinessUntypedException(
              _UntypedError(),
            ),
          ),
        ],
      );

      blocTest<_DryDataBloc, _DryDataState>(
        'Emits loading, then failure with fatal error, and rethrows',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwFatal),
        errors: () => [isA<_FatalException>()],
        expect: () => [
          const _DryDataState.loading(1),
          _DryDataState.failure(
            1,
            DryFatalException(_FatalException()),
          ),
        ],
      );
    });
    group('DryEmptyBloc', () {
      _DryEmptyBloc blocInitializer([_DryEmptyState? initialstate]) =>
          _DryEmptyBloc(
            repository: repo,
            initialState: initialstate,
          );

      blocTest<_DryEmptyBloc, _DryEmptyState>(
        'correct initial state(default one)',
        build: blocInitializer,
        verify: (bloc) =>
            expect(bloc.state, equals(const _DryEmptyState.initial())),
      );

      blocTest<_DryEmptyBloc, _DryEmptyState>(
        'correct initial state(passing)',
        build: () => blocInitializer(const DryEmptyState.loading()),
        verify: (bloc) =>
            expect(bloc.state, equals(const _DryEmptyState.loading())),
      );

      blocTest<_DryEmptyBloc, _DryEmptyState>(
        'Emits loading, then success',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.success),
        expect: () => [
          const _DryEmptyState.loading(),
          const _DryEmptyState.success(),
        ],
        verify: (bloc) {
          verify(() => bloc.repository.doSomething(_Event.success)).called(1);
        },
      );

      blocTest<_DryEmptyBloc, _DryEmptyState>(
        'Emits loading, then failure with business typed error',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwBusinessTyped),
        expect: () => [
          const _DryEmptyState.loading(),
          _DryEmptyState.failure(
            DryException.businessTyped(_TypedError()),
          ),
        ],
      );

      blocTest<_DryEmptyBloc, _DryEmptyState>(
        'Emits loading, then failure with business untyped error',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwBusinessUntyped),
        expect: () => [
          const _DryEmptyState.loading(),
          _DryEmptyState.failure(
            DryBusinessUntypedException(
              _UntypedError(),
            ),
          ),
        ],
      );

      blocTest<_DryEmptyBloc, _DryEmptyState>(
        'Emits loading, then failure with fatal error, and rethrows',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwFatal),
        errors: () => [isA<_FatalException>()],
        expect: () => [
          const _DryEmptyState.loading(),
          _DryEmptyState.failure(
            DryException.fatal(_FatalException()),
          ),
        ],
      );
    });
    group('DrySuccessDataBloc', () {
      _DrySuccessDataBloc blocInitializer([
        _DrySuccessDataState? initialstate,
      ]) {
        return _DrySuccessDataBloc(
          repository: repo,
          initialState: initialstate,
        );
      }

      blocTest<_DrySuccessDataBloc, _DrySuccessDataState>(
        'correct initial state(default one)',
        build: blocInitializer,
        verify: (bloc) =>
            expect(bloc.state, equals(const _DrySuccessDataState.initial())),
      );

      blocTest<_DrySuccessDataBloc, _DrySuccessDataState>(
        'correct initial state(passing)',
        build: () => blocInitializer(const DrySuccessDataState.loading()),
        verify: (bloc) =>
            expect(bloc.state, equals(const _DrySuccessDataState.loading())),
      );

      blocTest<_DrySuccessDataBloc, _DrySuccessDataState>(
        'Emits loading, then success',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.success),
        expect: () => [
          const _DrySuccessDataState.loading(),
          const _DrySuccessDataState.success(2),
        ],
        verify: (bloc) {
          verify(() => bloc.repository.doSomething(_Event.success)).called(1);
        },
      );

      blocTest<_DrySuccessDataBloc, _DrySuccessDataState>(
        'Emits loading, then failure with business typed error',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwBusinessTyped),
        expect: () => [
          const _DrySuccessDataState.loading(),
          _DrySuccessDataState.failure(
            DryBusinessTypedException(_TypedError()),
          ),
        ],
      );

      blocTest<_DrySuccessDataBloc, _DrySuccessDataState>(
        'Emits loading, then failure with business untyped error',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwBusinessUntyped),
        expect: () => [
          const _DrySuccessDataState.loading(),
          _DrySuccessDataState.failure(
            DryBusinessUntypedException(
              _UntypedError(),
            ),
          ),
        ],
      );

      blocTest<_DrySuccessDataBloc, _DrySuccessDataState>(
        'Emits loading, then failure with fatal error, and rethrows',
        build: blocInitializer,
        act: (bloc) => bloc.add(_Event.throwFatal),
        errors: () => [isA<_FatalException>()],
        expect: () => [
          const _DrySuccessDataState.loading(),
          _DrySuccessDataState.failure(
            DryFatalException(_FatalException()),
          ),
        ],
      );
    });
  });
}
