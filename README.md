[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

# DryBloc(Don't Repeat Yourself Bloc)

A Dart package that provides structured state management with the [BLoC](bloc_package_link) pattern, reducing boilerplate code and standardizing error handling.  Under the hood, it's a standard `Bloc` with its full API, but `dry_bloc` adds syntactic sugar, handles exceptions, and manages state transitions, making working with BLoC a breeze!

## Features:

* Standardized state types for various use cases
* Built-in error handling with typed exceptions
* Pattern matching for state handling
* Reduced boilerplate for common BLoC operations

## Example:

```dart
class LoadProfileEvent {
  const LoadProfileEvent();
}

typedef LoadProfileState = DrySuccessDataState<User, UserLoadError>;

class LoadProfileBloc
    extends DrySuccessDataBloc<LoadProfileEvent, User, UserLoadError> {
  LoadProfileBloc({required this.profileService}) {
    handle<LoadProfileEvent>((event) => profileService.loadUser());
  }

  @protected
  final ProfileService profileService;
}
```

That's all it takes!  With minimal code, `dry_bloc` handles the underlying complexities.

> Let's break down what's happening here. 

We'll start with the state. We've defined a `typedef` for convenience, making it easier to reference our `Bloc`'s state. But what is `DrySuccessDataState`, and what are the types (`<User, UserLoadError>`) passed as generics?

### State Types

There are four primary states when implementing an asynchronous operation:

  1. Initial
  2. Loading
  3. Success
  4. Failure

Our example above demonstrates this. We send a request to the server and wait for a response.

You've likely written many similar states. Even using [freezed](freezed_package_link) to reduce boilerplate, it's still quite verbose.  For example, these states implemented with `freezed` would look like this:

```dart
@freezed
sealed class LoadProfileState with _$LoadProfileState {
  const factory LoadProfileState.initial() = _LoadProfileInitialPage;
  const factory LoadProfileState.loading() = _LoadProfileLoadingState;
  const factory LoadProfileState.success(User user) = _LoadProfileSuccessState;
  const factory LoadProfileState.failure(UserLoadError error) = _LoadProfileFailureState;
}
```

And you're not done!  Code generation is still required.  Recent versions of `freezed` have also removed pattern-matching methods, adding complexity.

Now for the good news! `DrySuccessDataState<User, UserLoadError>` provides the same functionality as the `freezed` example, but *with* pattern-matching methods and *without* code generation!

> `DryBloc` offers three main state types: `DryEmptyState`, `DryDataState`, and `DrySuccessDataState`.


#### 1. DrySuccessDataState

You've already seen `DrySuccessDataState` in action. Like the others, it represents four states (Initial, Loading, Success, and Failure).  In the `Success` state, you receive the data resulting from the successful operation (in our example, the user data from the server).  This state (and the corresponding `DrySuccessDataBloc`) is ideal for loading data that should be available upon successful completion.

#### 2. DryEmptyState

This also represents four states, but all are empty (no data).  It's useful for asynchronous operations where you don't need the result.  It's equivalent to:

```dart
@freezed
sealed class LoadProfileState with _$LoadProfileState {
  const factory LoadProfileState.initial() = _LoadProfileInitialPage;
  const factory LoadProfileState.loading() = _LoadProfileLoadingState;
  const factory LoadProfileState.success() = _LoadProfileSuccessState;
  const factory LoadProfileState.failure(UserLoadError error) = _LoadProfileFailureState;
}
```

#### 3. DryDataState

This represents four states, each containing data.  It's useful when you need data in every state.  It's equivalent to:

```dart
@freezed
sealed class LoadProfileState with _$LoadProfileState {
  const factory LoadProfileState.initial(User user) = _LoadProfileInitialPage;
  const factory LoadProfileState.loading(User user) = _LoadProfileLoadingState;
  const factory LoadProfileState.success(User user) = _LoadProfileSuccessState;
  const factory LoadProfileState.failure(User user, UserLoadError error) = _LoadProfileFailureState;
}
```

### Pattern Matching

All state types support pattern matching for cleaner UI code:

```dart
state.when(
  initial: () => InitialView(),
  loading: () => LoadingView(),
  success: (data) => SuccessView(data: data),
  failure: (exc) => ErrorView(exception: exc),
);

// Or with nullable return
final message = state.whenOrNull(
  success: (data) => 'Success: ${data.length} items',
  failure: (exc) => 'Error: ${exc}',
);

// Or with default fallback
final widget = state.maybeWhen(
  orElse: (_) => DefaultView(),
  success: (data) => SuccessView(data: data),
);

```

> You can use these states independently or with their corresponding `DryBloc` classes::</br></br>
`DrySuccessDataState` with `DrySuccessDataBloc`</br>
`DryEmptyState` with `DryEmptyBloc`</br>
`DryDataState` with `DryDataBloc`

## DryBloc

Now, let's look at the `DryBloc` itself. What does it do under the hood? How does it manage state changes?

A common way to handle events might look like this:

```dart
Future<void> _handle(event, emit) async {
  emit(const LoadProfileState.loading());
  try {
    final result = await profileService.loadUser();

    emit(
      result.when(
        data: (user) => LoadProfileState.success(user),
        error: (e) => LoadProfileState.failure(e),
      ),
    );
  } on Object catch (e) {
    emit(const LoadProfileState.failure());

    rethrow;
  }
}
```

With `dry_bloc`, all you need to write is `profileService.loadUser()`.  `DryBloc`'s `handle` method takes care of the rest:

```dart
LoadProfileBloc({required this.profileService}) {
  handle<LoadProfileEvent>((event) => profileService.loadUser());
}
```

### Error Handling

The previous example uses a monad with two states: `Data` and `Error`:

```dart
result.when(
  data: (user) => LoadProfileState.success(user),
  error: (e) => LoadProfileState.failure(e),
),
```
`Result.error` is returned when an error occurs during normal application operation (a business logic error). This distinguishes between:

1. Fatal/critical exceptions (errors that shouldn't happen, like data parsing errors)
2. Business logic errors (e.g., attempting a Bluetooth operation when Bluetooth is off)

Exceptions caught in a `catch` block are considered fatal, while errors from the monad are business logic errors.

> `DryBloc` handles these exceptions for you, eliminating the need for monads and reducing code.

`dry_bloc` provides these exception types:

1. `DryFatalException`
2. `DryBusinessException`, which is further divided into:
    * `DryBusinessTypedException`
    * `DryBusinessUntypedException`

> How do you work with these?

The exception is delivered to your UI via `Dry*State.failure()`, allowing you to display the appropriate widget or error message based on the exception type:

```dart
BlocListener<VerifyForgotCodeBloc, VerifyForgotCodeState>(
  listener: (context, state) {
    state.whenOrNull(
      failure: (exc) {
        exc.when(
          fatal: (error) => /* Handle fatal error */,
          businessTyped: (error) => /* Handle typed business error */,
          businessUntyped: (error) => /* Handle untyped business error */,
        );
      },
    );
  },
),
```
> How does `DryBloc` classify exceptions?  

It uses the type parameter passed to the `DryBloc`:


```dart
class LoadProfileBloc
    extends DrySuccessDataBloc<LoadProfileEvent, User, UserLoadError> {
      /// ...
}
```
Here, `UserLoadError` represents a typed business logic error, which is non-fatal.  If your service throws a `UserLoadError` (or a subclass), `DryBloc` handles it and emits a failure state.  This replaces the need for monads. Instead of returning `Result.data()` or `Result.error()`, you return the result directly when successful and throw an error of the specified type when unsuccessful.

> What about `DryFatalException`?

Any other exception caught by `DryBloc` is considered fatal.  This allows you to log these errors (e.g., using `runZonedGuarded`'s `onError` callback) and report them to crash reporting services.

> Ok, and what's with `DryBusinessUntypedException`? How can we get those?

By default, you won't get those. This type of exception was introduced in case you don't want some exception to be threated as fatal, but, at the same time, for some reason, you don't want/can't mark it as business-logic typed(by passing its type to `DryBloc`).</br>
`DryBusinessUntypedException` occurs when an exception is marked as non-fatal but doesn't match the specified business logic error type.  To mark an exception as non-fatal:

1. **Globally:** Use `DryBloc.globalIsFatalException`.
2. **Bloc-scoped:** Override `isFatalException()`.
3. **Event-scoped:** Use the `isFatalExceptionOverride` parameter of the `handle` method.

You can also override `DryBloc.handle()` and `DryBloc.handleException()`.

All exceptions, after emitting the corresponding failure state, are rethrown, so you can catch them using the [Zone](https://api.flutter.dev/flutter/dart-async/Zone-class.html)s API. For example:

```dart
runZonedGuarded(
    () async {
        runApp(...);
    },
    (error, stack) {
        // This package also provides you the maybeWhenDryException() method
        // so you can easily pattern-match the exception
        error.maybeWhenDryException(
            // If you want to log to the Crashlytics only fatal exceptions
            businessTyped: (error) {},
            businessUntyped: (error) {},
            // In this case the fatal handler is redundant, it's just for demonstration
            fatal: (error) {
              FirebaseCrashlytics.instance.recordError(error, stack);
            },
            orElse: (error) {
              FirebaseCrashlytics.instance.recordError(error, stack);
            }
            );
    },
);
```

As you can see above, you are free to decide which exceptions to log and where to log them. The exception types are finely categorized.

---
### License
This project is licensed under the MIT License - see the LICENSE file for details.

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[bloc_package_link]: https://pub.dev/packages/bloc
[freezed_package_link]: https://pub.dev/packages/freezed