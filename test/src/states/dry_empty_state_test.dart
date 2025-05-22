import 'package:dry_bloc/dry_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('DryEmptyState', () {
    const initial = DryEmptyState<int>.initial();
    const loading = DryEmptyState<int>.loading();
    const success = DryEmptyState<int>.success();
    const failure = DryEmptyState<int>.failure(
      DryException.businessUntyped(1),
    );
    test(
      'equality implemented correctly',
      () {
        expect(
          const DryEmptyState.initial() == const DryEmptyState.initial(),
          isTrue,
        );
        expect(
          const DryEmptyState.loading() == const DryEmptyState.loading(),
          isTrue,
        );
        expect(
          const DryEmptyState.success() == const DryEmptyState.success(),
          isTrue,
        );
        expect(
          const DryEmptyState.failure(DryException.businessUntyped(1)) ==
              const DryEmptyState.failure(DryException.businessUntyped(1)),
          isTrue,
        );
        expect(
          const DryEmptyState.failure(DryException.businessTyped(2)) ==
              const DryEmptyState.failure(
                DryException.businessTyped(2),
              ),
          isTrue,
        );
        expect(
          const DryEmptyState.failure(DryException.businessUntyped(1)) ==
              const DryEmptyState.failure(
                DryException.businessUntyped(2),
              ),
          isFalse,
        );
        expect(
          {
            const DryEmptyState.initial(),
            const DryEmptyState.loading(),
            const DryEmptyState.success(),
            const DryEmptyState.failure(DryException.businessUntyped(1)),
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
          success: () => 3,
          failure: (_) => 4,
        ),
        equals(1),
      );
      expect(
        loading.when(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
        ),
        equals(2),
      );
      expect(
        success.when(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
        ),
        equals(3),
      );
      expect(
        failure.when(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
        ),
        equals(4),
      );
      expect(
        const DryEmptyState.failure(DryException.businessUntyped(5)).when(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (e) => e,
        ),
        equals(const DryException.businessUntyped(5)),
      );
    });

    test('whenOrNull pattern-matching method', () {
      expect(
        initial.whenOrNull(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (e) => e,
        ),
        equals(1),
      );
      expect(
        loading.whenOrNull(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (e) => e,
        ),
        equals(2),
      );
      expect(
        success.whenOrNull(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (e) => e,
        ),
        equals(3),
      );
      expect(
        failure.whenOrNull(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
        ),
        equals(4),
      );
      expect(
        const DryEmptyState<String>.failure(
          DryException.businessTyped('5'),
        ).whenOrNull(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (e) => e,
        ),
        equals(const DryException.businessTyped('5')),
      );

      // when null
      expect(
        initial.whenOrNull(
          loading: () => 2,
          success: () => 3,
          failure: (exc) => 4,
        ),
        isNull,
      );
      expect(
        loading.whenOrNull(
          initial: () => 1,
          success: () => 3,
          failure: (exc) => 4,
        ),
        isNull,
      );
      expect(
        success.whenOrNull(
          initial: () => 1,
          loading: () => 2,
          failure: (exc) => 4,
        ),
        isNull,
      );
      expect(
        failure.whenOrNull(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
        ),
        isNull,
      );
    });

    test('maybeWhen pattern-matching method', () {
      expect(
        initial.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
          orElse: () => 5,
        ),
        equals(1),
      );
      //
      expect(
        loading.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
          orElse: () => 5,
        ),
        equals(2),
      );
      //
      expect(
        success.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
          orElse: () => 5,
        ),
        equals(3),
      );
      expect(
        failure.maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (_) => 4,
          orElse: () => 5,
        ),
        equals(4),
      );
      expect(
        const DryEmptyState.failure(DryException.businessUntyped(6)).maybeWhen(
          initial: () => 1,
          loading: () => 2,
          success: () => 3,
          failure: (e) => e,
          orElse: () => 5,
        ),
        equals(const DryException.businessUntyped(6)),
      );
      expect(initial.maybeWhen(orElse: () => false), isFalse);
      expect(loading.maybeWhen(orElse: () => false), isFalse);
      expect(success.maybeWhen(orElse: () => false), isFalse);
      expect(failure.maybeWhen(orElse: () => false), isFalse);
    });

    test(
      'copyWith method',
      () {
        expect(
          initial.copyWith(const DryException.businessUntyped(3)),
          equals(const DryEmptyState<int>.initial()),
        );
        expect(
          loading.copyWith(const DryException.businessUntyped(3)),
          equals(const DryEmptyState<int>.loading()),
        );
        expect(
          success.copyWith(const DryException.businessUntyped(3)),
          equals(const DryEmptyState<int>.success()),
        );
        expect(
          failure.copyWith(const DryException.businessUntyped(3)),
          equals(
            const DryEmptyState<int>.failure(
              DryException.businessUntyped(3),
            ),
          ),
        );
      },
    );

    test('in* initializer method', () {
      expect(loading.inInitial(), equals(const DryEmptyState<int>.initial()));
      expect(initial.inLoading(), equals(const DryEmptyState<int>.loading()));
      expect(initial.inSuccess(), equals(const DryEmptyState<int>.success()));
      expect(
        initial.inFailure(const DryException.businessUntyped(6)),
        equals(
          const DryEmptyState<int>.failure(DryException.businessUntyped(6)),
        ),
      );
      expect(
        initial.inFailure(const DryException.businessUntyped(6)),
        equals(
          const DryEmptyState<int>.failure(DryException.businessUntyped(6)),
        ),
      );
    });
  });
}
