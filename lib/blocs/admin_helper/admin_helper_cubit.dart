import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'admin_helper_state.dart';

class AdminHelperCubit extends Cubit<AdminHelperState> {
  AdminHelperCubit() : super(AdminHelperInitial());
  get isAdmin => _isAdmin;
  bool _isAdmin = false;
  void setIsAdmin(bool value) {
    _isAdmin = value;
    emit(_isAdmin ? AdminLoggedIn() : AdminLoggedOut());
  }
}
