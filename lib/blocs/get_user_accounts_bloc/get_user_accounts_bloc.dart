import 'package:bloc/bloc.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:meta/meta.dart';

part 'get_user_accounts_event.dart';
part 'get_user_accounts_state.dart';

class GetUserAccountsBloc extends Bloc<GetUserAccountsEvent, GetUserAccountsState> {
  final AccountRepository accountRepository;
  GetUserAccountsBloc(this.accountRepository) : super(GetUserAccountsInitial()) {
    on<FetchUserAccounts>((event, emit) async {
      try {
        emit(FetchingInProgress());
        final accounts = await accountRepository.fetchUserAccounts();
        emit(AccountsFetchSuccess(accounts));
      } catch (e) {
        emit(AccountFetchError(e));
      }
    });
  }
}
