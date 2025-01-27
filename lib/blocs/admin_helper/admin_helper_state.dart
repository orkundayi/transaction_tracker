part of 'admin_helper_cubit.dart';

@immutable
sealed class AdminHelperState {}

final class AdminHelperInitial extends AdminHelperState {}

final class AdminLoggedIn extends AdminHelperState {}

final class AdminLoggedOut extends AdminHelperState {}
