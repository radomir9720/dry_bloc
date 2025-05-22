import 'package:equatable/equatable.dart';

/// Base state.
///
/// - [Error] - type of business errors
abstract class DryState<E extends Object> with EquatableMixin {}
