import 'package:bloc/bloc.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:meta/meta.dart';

part 'user_account_state.dart';

class UserAccountCubit extends Cubit<UserAccountState> {
  UserAccountCubit() : super(UserAccountInitial());

  void updateIndex(int newIndex, AccountModel? account) {
    emit(UserAccountIndexUpdated(newIndex, account));
  }
}
