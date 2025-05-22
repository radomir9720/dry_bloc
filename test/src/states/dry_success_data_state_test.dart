import 'package:dry_bloc/dry_bloc.dart';
import 'package:test/test.dart';

typedef _State = DrySuccessDataState<int, String>;

void main() {
  group('DrySuccessDataState', () {
    const initial = _State.initial();
    const loading = _State.loading();
    const success = _State.success(3);
    const failure = _State.failure(DryException.fatal(1));
    test(
      'equality implemented correctly',
      () {
        expect(const _State.initial() == const _State.initial(), isTrue);
        expect(const _State.loading() == const _State.loading(), isTrue);
        expect(const _State.success(1) == const _State.success(1), isTrue);
        expect(
          const _State.failure(DryException.fatal(1)) ==
              const _State.failure(DryException.fatal(1)),
          isTrue,
        );
        expect(
          const _State.failure(DryException.businessUntyped(2)) ==
              const _State.failure(DryException.businessUntyped(2)),
          isTrue,
        );
        expect(
          const _State.failure(DryException.fatal(1)) ==
              const _State.failure(DryException.fatal(2)),
          isFalse,
        );
        expect(
          {
            const _State.initial(),
            const _State.loading(),
            const _State.success(1),
            const _State.failure(DryException.fatal(1)),
          }.length,
          equals(4),
        );
      },
    );

    test('is* getters implemented correctly', () {
      // initial
      expect(initial.isInitial, isTrue);
      expect(initial.isLoading, isFalse);
      expect(initial.isSuccess, isFalse);
      expect(initial.isFailure, isFalse);
      expect(initial.isExecuted, isFalse);
      // loading
      expect(loading.isLoading, isTrue);
      expect(loading.isInitial, isFalse);
      expect(loading.isSuccess, isFalse);
      expect(loading.isFailure, isFalse);
      expect(loading.isExecuted, isFalse);
      // success
      expect(success.isSuccess, isTrue);
      expect(success.isInitial, isFalse);
      expect(success.isLoading, isFalse);
      expect(success.isFailure, isFalse);
      expect(success.isExecuted, isTrue);
      //
      expect(failure.isFailure, isTrue);
      expect(failure.isInitial, isFalse);
      expect(failure.isLoading, isFalse);
      expect(failure.isSuccess, isFalse);
      expect(failure.isExecuted, isTrue);
    });

    test('when() pattern-matching method', () {
      expect(
        initial.when(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (_) => 4,
        ),
        equals(1),
      );
      expect(
        loading.when(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (_) => 4,
        ),
        equals(2),
      );
      expect(
        success.when(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (_) => 4,
        ),
        equals(3),
      );
      expect(
        failure.when(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (_) => 4,
        ),
        equals(4),
      );
      expect(
        const _State.failure(DryException.fatal('5')).when(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (e) => e,
        ),
        equals(const DryException<String>.fatal('5')),
      );
    });

    test('maybeWhen pattern-matching method', () {
      expect(
        initial.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (e) => e,
          orElse: (_) => 5,
        ),
        equals(1),
      );
      //
      expect(
        loading.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (e) => e,
          orElse: (_) => 5,
        ),
        equals(2),
      );
      //
      expect(
        success.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (e) => e,
          orElse: (_) => 5,
        ),
        equals(3),
      );
      expect(
        failure.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (_) => 4,
          orElse: (_) => 5,
        ),
        equals(4),
      );
      expect(
        const _State.failure(DryException.fatal('6')).maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: (d) => d,
          failure: (e) => e,
          orElse: (_) => 7,
        ),
        equals(const DryException<String>.fatal('6')),
      );
      expect(initial.maybeWhen(orElse: (d) => d ?? 1), equals(1));
      expect(loading.maybeWhen(orElse: (d) => d ?? 2), equals(2));
      expect(success.maybeWhen(orElse: (d) => d ?? 5), equals(3));
      expect(failure.maybeWhen(orElse: (d) => d ?? 4), equals(4));
    });

    test('copyWith method', () {
      expect(
        initial.copyWith(
          data: 5,
          exc: const DryException.fatal('error'),
        ),
        equals(const _State.initial()),
      );
      expect(
        loading.copyWith(
          data: 5,
          exc: const DryException.fatal('error'),
        ),
        equals(const _State.loading()),
      );
      expect(
        success.copyWith(
          data: 5,
          exc: const DryException.fatal('error'),
        ),
        equals(const _State.success(5)),
      );
      expect(
        failure.copyWith(
          data: 5,
          exc: const DryException.fatal('error'),
        ),
        equals(const _State.failure(DryException.fatal('error'))),
      );
    });

    test('in* initializer method', () {
      expect(
        loading.inInitial(),
        equals(const _State.initial()),
      );
      expect(
        initial.inLoading(),
        equals(const _State.loading()),
      );
      expect(
        initial.inSuccess(5),
        equals(const _State.success(5)),
      );
      expect(
        initial.inFailure(const DryException.fatal(1)),
        equals(const _State.failure(DryException.fatal(1))),
      );
      expect(
        initial.inFailure(const DryException.fatal('3')),
        equals(const _State.failure(DryException.fatal('3'))),
      );
    });
  });
}
