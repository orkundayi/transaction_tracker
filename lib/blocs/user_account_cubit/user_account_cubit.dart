import 'package:bloc/bloc.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:meta/meta.dart';

part 'user_account_state.dart';

class UserAccountCubit extends Cubit<UserAccountState> {
  UserAccountCubit() : super(UserAccountInitial());
  int _currentIndex = 0;
  AccountModel? _currentAccount;
  AccountModel? _previousAccount;

  int get currentIndex => _currentIndex;
  AccountModel? get currentAccount => _currentAccount;
  AccountModel? get previousAccount => _previousAccount;

  void updateIndex(int newIndex, AccountModel? account) {
    final selectedAccount = account;
    try {
      emit(UserAccountIndexUpdating());
      _currentIndex = newIndex;
      _previousAccount = _currentAccount;
      _currentAccount = selectedAccount;
      emit(UserAccountIndexUpdated());
    } catch (e) {
      emit(UserAccountIndexUpdateError(e));
    }
  }
}
