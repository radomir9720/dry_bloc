import 'dart:math';

import 'package:dry_bloc/dry_bloc.dart';

// Example of DrySuccessDataBloc
class LoadProfileEvent {
  const LoadProfileEvent(this.id);

  final int id;
}

typedef LoadProfileState = DrySuccessDataState<User, LoadUserError>;

class LoadProfileBloc
    extends DrySuccessDataBloc<LoadProfileEvent, User, LoadUserError> {
  LoadProfileBloc({required this.profileService}) {
    handle<LoadProfileEvent>((event) => profileService.loadUser(event.id));
  }

  final ProfileService profileService;
}

// Example of DryEmptyBloc
class DeleteUserEvent {
  const DeleteUserEvent();
}

typedef DeleteUserState = DryEmptyState<DeleteUserError>;

class DeleteUserBloc extends DryEmptyBloc<DeleteUserEvent, DeleteUserError> {
  DeleteUserBloc({required this.profileService}) {
    handle<DeleteUserEvent>((event) => profileService.deleteUser());
  }

  final ProfileService profileService;
}

// Example of DryDataBloc
class UpdateProfileEvent {
  const UpdateProfileEvent(this.user);

  final User user;
}

typedef UpdateProfileState = DryDataState<User, UpdateUserError>;

class UpdateProfileBloc
    extends DryDataBloc<UpdateProfileEvent, User, UpdateUserError> {
  UpdateProfileBloc(super.initialState, {required this.profileService}) {
    handle<UpdateProfileEvent>(
      (event) => profileService.updateUser(event.user),
    );
  }

  final ProfileService profileService;
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
