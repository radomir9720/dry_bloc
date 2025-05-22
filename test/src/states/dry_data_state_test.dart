import 'package:dry_bloc/dry_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('DryDataState', () {
    const initial = DryDataState<int, String>.initial(1);
    const loading = DryDataState<int, String>.loading(2);
    const success = DryDataState<int, String>.success(3);
    const failure = DryDataState<int, String>.failure(
      4,
      DryException.businessTyped('5'),
    );
    test(
      'equality implemented correctly',
      () {
        expect(
          const DryDataState.initial(1) == const DryDataState.initial(1),
          isTrue,
        );
        expect(
          const DryDataState.loading(1) == const DryDataState.loading(1),
          isTrue,
        );
        expect(
          const DryDataState.success(1) == const DryDataState.success(1),
          isTrue,
        );
        expect(
          const DryDataState.failure(
                1,
                DryException.businessTyped('5'),
              ) ==
              const DryDataState.failure(
                1,
                DryException.businessTyped('5'),
              ),
          isTrue,
        );
        expect(
          const DryDataState.failure(1, DryFatalException({})) ==
              const DryDataState.failure(1, DryFatalException({})),
          isTrue,
        );
        expect(
          const DryDataState.failure(1, DryFatalException({})) ==
              const DryDataState.failure(2, DryFatalException({})),
          isFalse,
        );
        expect(
          {
            const DryDataState.initial(1),
            const DryDataState.loading(1),
            const DryDataState.success(1),
            const DryDataState.failure(1, DryFatalException({})),
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
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, __) => d,
        ),
        equals(1),
      );
      expect(
        loading.when(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, __) => d,
        ),
        equals(2),
      );
      expect(
        success.when(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, __) => d,
        ),
        equals(3),
      );
      expect(
        failure.when(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, __) => d,
        ),
        equals(4),
      );
      expect(
        const DryDataState<int, String>.failure(
          4,
          DryException.businessTyped('5'),
        ).when(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, e) => e,
        ),
        equals(const DryException.businessTyped('5')),
      );
    });

    test('maybeWhen pattern-matching method', () {
      expect(
        initial.maybeWhen(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, _) => d,
          orElse: (_) => 5,
        ),
        equals(1),
      );
      //
      expect(
        loading.maybeWhen(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, _) => d,
          orElse: (_) => 5,
        ),
        equals(2),
      );
      //
      expect(
        success.maybeWhen(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, _) => d,
          orElse: (_) => 5,
        ),
        equals(3),
      );
      expect(
        failure.maybeWhen(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, _) => d,
          orElse: (_) => 5,
        ),
        equals(4),
      );
      expect(
        const DryDataState<int, String>.failure(
          4,
          DryException.businessTyped('5'),
        ).maybeWhen(
          initial: (d) => d,
          loading: (d) => d,
          success: (d) => d,
          failure: (d, e) => e,
          orElse: (_) => 7,
        ),
        equals(const DryException.businessTyped('5')),
      );
      expect(initial.maybeWhen(orElse: (d) => d), equals(1));
      expect(loading.maybeWhen(orElse: (d) => d), equals(2));
      expect(success.maybeWhen(orElse: (d) => d), equals(3));
      expect(failure.maybeWhen(orElse: (d) => d), equals(4));
    });

    test('copyWith method', () {
      // expect(
      //   initial.copyWith(
      //     data: 5,
      //     exc: const DryException.businessTyped('error'),
      //   ),
      //   equals(const DryDataState<int, String>.initial(5)),
      // );
      // expect(
      //   loading.copyWith(
      //     data: 5,
      //     exc: const DryException.businessTyped('error'),
      //   ),
      //   equals(const DryDataState<int, String>.loading(5)),
      // );
      // expect(
      //   success.copyWith(
      //     data: 5,
      //     exc: const DryException.businessTyped('error'),
      //   ),
      //   equals(const DryDataState<int, String>.success(5)),
      // );
      expect(
        failure.copyWith(
          data: 5,
          exc: const DryException.businessTyped('error'),
        ),
        equals(
          const DryDataState<int, String>.failure(
            5,
            DryException.businessTyped('error'),
          ),
        ),
      );
    });

    test('in* initializer method', () {
      expect(
        loading.inInitial(),
        equals(const DryDataState<int, String>.initial(2)),
      );
      expect(
        initial.inLoading(),
        equals(const DryDataState<int, String>.loading(1)),
      );
      expect(
        initial.inSuccess(),
        equals(const DryDataState<int, String>.success(1)),
      );
      expect(
        initial.inFailure(const DryException.businessTyped('error')),
        equals(
          const DryDataState<int, String>.failure(
            1,
            DryException.businessTyped('error'),
          ),
        ),
      );
      expect(
        initial.inFailure(
          const DryException.businessTyped('3'),
        ),
        equals(
          const DryDataState<int, String>.failure(
            1,
            DryException.businessTyped('3'),
          ),
        ),
      );
    });
  });
}
