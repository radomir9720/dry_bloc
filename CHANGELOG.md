# 1.0.0

- **BREAKING** refactor!: rethrow all the exceptions
- **BREAKING** refactor!: make `DryException` implement `Exception`
- feat: introduce `maybeWhenDryException()` extension method
  
  Example of usage:
  ```dart
    runZonedGuarded(
        () async {
            runApp(...);
        },
        (error, stack) {
            error.maybeWhenDryException(
                // If you want to log to the Crashlytics only fatal exceptions
                businessTyped: (error) {},
                businessUntyped: (error) {},
                orElse: (error) =>
                    FirebaseCrashlytics.instance.recordError(error, stack),
                );
        },
    );
  ```

# 0.1.0+1

- feat: initial commit 🎉
