import 'package:bloc/bloc.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:meta/meta.dart';

part 'create_user_account_event.dart';
part 'create_user_account_state.dart';

class CreateUserAccountBloc extends Bloc<CreateUserAccountEvent, CreateUserAccountState> {
  final AccountRepository accountRepository;
  CreateUserAccountBloc(this.accountRepository) : super(CreateUserAccountInitial()) {
    on<CreateUserAccount>((event, emit) {
      try {
        emit(CreateUserAccountInProgress());
        AccountModel account = event.account;
        accountRepository.createUserAccount(account);
        emit(CreateUserAccountSuccess());
      } catch (e) {
        emit(CreateUserAccountError(e));
      }
    });
  }
}
