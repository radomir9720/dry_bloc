import 'package:dry_bloc/dry_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('MaybeWhenDryExceptionExtension', () {
    group('maybeWhenDryException', () {
      test(
          'should call corresponding handler when it is provided, '
          'and object is DryException', () {
        expect(
          const DryFatalException(true).maybeWhenDryException(
            orElse: (error) => throw Exception(),
            businessTyped: (error) => throw Exception(),
            businessUntyped: (error) => throw Exception(),
            fatal: (error) => error,
          ),
          isTrue,
        );
        expect(
          const DryException.businessTyped(true).maybeWhenDryException(
            orElse: (error) => throw Exception(),
            businessTyped: (error) => error,
            businessUntyped: (error) => throw Exception(),
            fatal: (error) => throw Exception(),
          ),
          isTrue,
        );
        expect(
          const DryException.businessUntyped(true).maybeWhenDryException(
            orElse: (error) => throw Exception(),
            businessTyped: (error) => throw Exception(),
            businessUntyped: (error) => error,
            fatal: (error) => throw Exception(),
          ),
          isTrue,
        );
      });
      test(
          'should call orElse handler when appropriated handler is not '
          'provided, and object is DryException', () {
        expect(
          const DryFatalException(true).maybeWhenDryException(
            orElse: (error) => error,
            businessTyped: (error) => throw Exception(),
            businessUntyped: (error) => throw Exception(),
          ),
          isTrue,
        );
        expect(
          const DryException.businessTyped(true).maybeWhenDryException(
            orElse: (error) => error,
            businessUntyped: (error) => throw Exception(),
            fatal: (error) => throw Exception(),
          ),
          isTrue,
        );
        expect(
          const DryException.businessUntyped(true).maybeWhenDryException(
            orElse: (error) => error,
            businessTyped: (error) => throw Exception(),
            fatal: (error) => throw Exception(),
          ),
          isTrue,
        );
      });
      test('should call orElse handler when object is not a DryException', () {
        expect(
          1.maybeWhenDryException(
            orElse: (error) => error,
            fatal: (error) => throw Exception(),
            businessTyped: (error) => throw Exception(),
            businessUntyped: (error) => throw Exception(),
          ),
          equals(1),
        );
        expect(
          'Some string'.maybeWhenDryException(
            orElse: (error) => error,
            fatal: (error) => throw Exception(),
            businessTyped: (error) => throw Exception(),
            businessUntyped: (error) => throw Exception(),
          ),
          equals('Some string'),
        );
      });
    });
  });
}
