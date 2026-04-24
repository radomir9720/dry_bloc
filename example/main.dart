import 'dart:math';

import 'package:dry_bloc/dry_bloc.dart';

/// =================  Example of DryEmptyBloc ===================
class DeleteUserEvent {
  const DeleteUserEvent();
}

typedef DeleteUserState = DryEmptyState<DeleteUserError>;

/// Option 1. Extending the [DryEmptyBloc]
class DeleteUserBloc extends DryEmptyBloc<DeleteUserEvent, DeleteUserError> {
  DeleteUserBloc({required ProfileService profileService}) {
    handle<DeleteUserEvent>((event) => profileService.deleteUser());
  }
}

/// Option 2. Extending the [DryEmptySingleEventBloc].
/// It's the same as Option 1, except this bloc knows that you'll have only
/// one event, therefore this bloc will call the [handle] method for you,
/// so you have to write less symbols
class DeleteSingleEventUserBloc
    extends DryEmptySingleEventBloc<DeleteUserEvent, DeleteUserError> {
  DeleteSingleEventUserBloc({required ProfileService profileService})
      : super(action: (_) => profileService.deleteUser());
}

/// Option 3. Extending the [DryEmptySingleVoidEventBloc].
/// The same as Option 2, except this bloc knows that your event
/// is empty(you won't pass any data), because your service method doesn't need
/// any data.
class DeleteSingleVoidEventUserBloc
    extends DryEmptySingleVoidEventBloc<DeleteUserError> {
  DeleteSingleVoidEventUserBloc({required ProfileService profileService})
      : super(action: profileService.deleteUser);
}

/// Option 4. The same as Option 3, but instead of passing the service into the
/// constructor you pass the service method when you're constructing an object
/// of this bloc:
///
/// ```dart
///
/// DeleteSingleVoidEventUserBloc2(
///   action: context.read<ProfileService>().deleteUser
/// );
/// ```
///
/// It's the most compact way to write a bloc, but i, personally, would
/// recommend using the Option 3, because, IMHO, by leaving the responsibility
/// of passing the right action(method) through the constructor you are, kind
/// of, passing some bussiness logic outside the bloc.
class DeleteSingleVoidEventUserBloc2
    extends DryEmptySingleVoidEventBloc<DeleteUserError> {
  DeleteSingleVoidEventUserBloc2({required super.action});
}

/// ================= Example of DrySuccessDataBloc =================
class LoadProfileEvent {
  const LoadProfileEvent(this.id);

  final int id;
}

typedef LoadProfileState = DrySuccessDataState<User, LoadUserError>;

/// Option 1. Extends [DrySuccessDataBloc].
class LoadProfileBloc
    extends DrySuccessDataBloc<LoadProfileEvent, User, LoadUserError> {
  LoadProfileBloc({required ProfileService profileService}) {
    handle<LoadProfileEvent>((event) => profileService.loadUser(event.id));
  }
}

/// Option 2. Extending the [DrySuccessDataSingleEventBloc].
/// It's the same as Option 1, except this bloc knows that you'll have only
/// one event, therefore this bloc will call the [handle] method for you,
/// so you have to write less symbols.
///
/// Also, we can get rid of [LoadProfileEvent] and use directly [int] as the
/// event type. So instead of adding an event containing the user id,
/// you'll add directly the user id as the event:
/// [LoadProfileSingleEventUserBloc().addSingleEvent(userId)]
class LoadProfileSingleEventUserBloc
    extends DrySuccessDataSingleEventBloc<int, User, LoadUserError> {
  LoadProfileSingleEventUserBloc({required ProfileService profileService})
      : super(action: (userId) => profileService.loadUser(userId));
  // or the tear-off syntax:
  // : super(action: profileService.loadUser);
}

/// Option 3. The same as Option 2, but instead of passing the service into the
/// constructor you pass the service method when you're constructing an object
/// of this bloc:
///
/// ```dart
///
/// LoadProfileSingleEventUserBloc2(
///   action: (event) => context.read<ProfileService>().loadUser(event.id)
/// );
/// ```
///
/// It's the most compact way to write a bloc, but i, personally, would
/// recommend using the Option 2, because, IMHO, by leaving the responsibility
/// of passing the right action(method) through the constructor you are, kind
/// of, passing some bussiness logic outside the bloc.
class LoadProfileSingleEventUserBloc2 extends DrySuccessDataSingleEventBloc<
    LoadProfileEvent, User, LoadUserError> {
  LoadProfileSingleEventUserBloc2({required super.action});
}

/// ================= Example of DryDataBloc =================
class UpdateProfileEvent {
  const UpdateProfileEvent(this.user);

  final User user;
}

typedef UpdateProfileState = DryDataState<User, UpdateUserError>;

/// Option 1. Extending [DryDataBloc]. Using [UpdateProfileEvent] as event.
class UpdateProfileBloc
    extends DryDataBloc<UpdateProfileEvent, User, UpdateUserError> {
  UpdateProfileBloc(
    super.initialState, {
    required ProfileService profileService,
  }) {
    handle<UpdateProfileEvent>(
      (event) => profileService.updateUser(event.user),
    );
  }
}

/// Oprion 2. Extends [DryDataSingleEventBloc]. Using [User] as event.
/// It's the same as Option 1, except this bloc knows that you'll have only
/// one event, therefore this bloc will call the [handle] method for you,
/// so you have to write less symbols
class UpdateProfileSingleEventBloc
    extends DryDataSingleEventBloc<User, User, UpdateUserError> {
  UpdateProfileSingleEventBloc(
    super.initialState, {
    required ProfileService profileService,
  }) : super(action: profileService.updateUser);
}

/// Option 3. The same as Option 2, but instead of passing the service into the
/// constructor you pass the service method when you're constructing an object
/// of this bloc:
///
/// ```dart
///
/// UpdateProfileSingleEventBloc2(
///   DryDataState.initial(User()),
///   action: context.read<ProfileService>().loadUser,
/// )
/// ```
///
/// It's the most compact way to write a bloc, but i, personally, would
/// recommend using the Option 2, because, IMHO, by leaving the responsibility
/// of passing the right action(method) through the constructor you are, kind
/// of, passing some bussiness logic outside the bloc.
class UpdateProfileSingleEventBloc2
    extends DryDataSingleEventBloc<User, User, UpdateUserError> {
  UpdateProfileSingleEventBloc2(
    super.initialState, {
    required super.action,
  });
}

//

class User {}

final class ProfileService {
  Future<User> loadUser(int id) async {
    if (Random().nextBool()) {
      throw SomeLoadUserError(); // Throw a typed business-logic error
    }
    return User();
  }

  Future<void> deleteUser() async {
    if (Random().nextBool()) {
      throw SomeDeleteUserError(); // Throw a typed business-logic error
    }
  }

  Future<User> updateUser(User user) async {
    if (Random().nextBool()) {
      throw SomeDeleteUserError(); // Throw a typed business-logic error
    }
    return user;
  }
}

abstract class LoadUserError implements Exception {}

final class SomeLoadUserError extends LoadUserError {}

abstract class DeleteUserError implements Exception {}

final class SomeDeleteUserError implements DeleteUserError {}

abstract class UpdateUserError implements Exception {}

final class SomeUpdateUserError implements DeleteUserError {}
