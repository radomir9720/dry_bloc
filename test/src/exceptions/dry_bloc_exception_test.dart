import 'package:dry_bloc/dry_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('DryException', () {
    group('when', () {
      test('calls correct handler', () {
        expect(
          const DryException.fatal(1).when(
            fatal: (error) => (error, 'fatal'),
            businessTyped: (error) => 'businessTyped',
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals((1, 'fatal')),
        );
        expect(
          const DryException.businessTyped(2).when(
            fatal: (error) => (error, 'fatal'),
            businessTyped: (error) => (error, 'businessTyped'),
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals((2, 'businessTyped')),
        );
        expect(
          const DryException.businessUntyped(3).when(
            fatal: (error) => (error, 'fatal'),
            businessTyped: (error) => (error, 'businessTyped'),
            businessUntyped: (error) => (error, 'businessUntyped'),
          ),
          equals((3, 'businessUntyped')),
        );
      });

      test('calls correct handler for typed business exception', () {
        const exception = DryException.businessTyped(10);
        final result = exception.when<String>(
          fatal: (error) => 'fatal',
          businessTyped: (error) => 'businessTyped',
          businessUntyped: (error) => 'businessUntyped',
        );
        expect(result, 'businessTyped');
      });

      test('calls correct handler for untyped business exception', () {
        const exception = DryException.businessUntyped('business error');
        final result = exception.when(
          fatal: (error) => 'fatal',
          businessTyped: (error) => 'businessTyped',
          businessUntyped: (error) => 'businessUntyped',
        );
        expect(result, 'businessUntyped');
      });
    });

    group('whenOrNull', () {
      test('calls correct handler', () {
        expect(
          const DryException.fatal(1).whenOrNull(
            fatal: (error) => (1, 'fatal'),
            businessTyped: (error) => 'businessTyped',
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals((1, 'fatal')),
        );
        expect(
          const DryException.businessTyped(2).whenOrNull(
            fatal: (error) => 'fatal',
            businessTyped: (error) => (error, 'businessTyped'),
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals((2, 'businessTyped')),
        );
        expect(
          const DryException.businessUntyped(3).whenOrNull(
            fatal: (error) => 'fatal',
            businessTyped: (error) => 'businessTyped',
            businessUntyped: (error) => (error, 'businessUntyped'),
          ),
          equals((3, 'businessUntyped')),
        );
      });

      test('returns null when no matching handler is provided', () {
        expect(
          const DryException.fatal('fatal error').whenOrNull(
            businessTyped: (error) => 'businessTyped',
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals(null),
        );
        expect(
          const DryException.businessTyped(1).whenOrNull(
            fatal: (error) => 'fatal',
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals(null),
        );
        expect(
          const DryException.businessUntyped(2).whenOrNull(
            fatal: (error) => 'fatal',
            businessTyped: (error) => 'businessTyped',
          ),
          equals(null),
        );
      });
    });

    group('maybeWhen', () {
      test('calls correct handler', () {
        expect(
          const DryException.fatal(1).maybeWhen(
            orElse: (error) => 'orElse',
            fatal: (error) => (error, 'fatal'),
            businessTyped: (error) => 'businessTyped',
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals((1, 'fatal')),
        );
        expect(
          const DryException.businessTyped(2).maybeWhen(
            orElse: (error) => 'orElse',
            fatal: (error) => (error, 'fatal'),
            businessTyped: (error) => (error, 'businessTyped'),
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals((2, 'businessTyped')),
        );
        expect(
          const DryException.businessUntyped(3).maybeWhen(
            orElse: (error) => 'orElse',
            fatal: (error) => (error, 'fatal'),
            businessTyped: (error) => (error, 'businessTyped'),
            businessUntyped: (error) => (error, 'businessUntyped'),
          ),
          equals((3, 'businessUntyped')),
        );
      });

      test('calls orElse when no matching handler is provided', () {
        expect(
          const DryException.fatal('fatal error').maybeWhen(
            orElse: (error) => (error, 'orElse'),
            businessTyped: (error) => 'businessTyped',
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals(('fatal error', 'orElse')),
        );
        expect(
          const DryException.businessTyped(1).maybeWhen(
            orElse: (error) => (error, 'orElse'),
            fatal: (error) => 'fatal',
            businessUntyped: (error) => 'businessUntyped',
          ),
          equals((1, 'orElse')),
        );
        expect(
          const DryException.businessUntyped(2).maybeWhen(
            orElse: (error) => (error, 'orElse'),
            fatal: (error) => 'fatal',
            businessTyped: (error) => 'businessTyped',
          ),
          equals((2, 'orElse')),
        );
      });
    });

    group('Type Checks', () {
      test(
          'isFatal, isBusiness, isBusinessTyped, isBusinessUntyped '
          'for DryFatalException', () {
        const exception = DryException.fatal('fatal error');
        expect(exception.isFatal, true);
        expect(exception.isBusiness, false);
        expect(exception.isBusinessTyped, false);
        expect(exception.isBusinessUntyped, false);
      });

      test(
          'isFatal, isBusiness, isBusinessTyped, isBusinessUntyped '
          'for DryBusinessTypedException', () {
        const exception = DryException.businessTyped(10);
        expect(exception.isFatal, false);
        expect(exception.isBusiness, true);
        expect(exception.isBusinessTyped, true);
        expect(exception.isBusinessUntyped, false);
      });

      test(
          'isFatal, isBusiness, isBusinessTyped, '
          'isBusinessUntyped for DryBusinessUntypedException', () {
        const exception = DryException.businessUntyped('business error');
        expect(exception.isFatal, false);
        expect(exception.isBusiness, true);
        expect(exception.isBusinessTyped, false);
        expect(exception.isBusinessUntyped, true);
      });
    });
  });
}
