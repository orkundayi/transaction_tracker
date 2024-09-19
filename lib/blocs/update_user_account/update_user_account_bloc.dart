import 'package:bloc/bloc.dart';
import 'package:firebase_repository/firebase_repository.dart';
import 'package:meta/meta.dart';

part 'update_user_account_event.dart';
part 'update_user_account_state.dart';

class UpdateUserAccountBloc extends Bloc<UpdateUserAccountEvent, UpdateUserAccountState> {
  final AccountRepository accountRepository;
  UpdateUserAccountBloc(this.accountRepository) : super(UpdateUserAccountInitial()) {
    on<UpdateUserAccountEvent>((event, emit) {
      emit(UpdateUserAccountLoading());
      accountRepository.updateUserAccount(event.transaction).then((_) {
        emit(UpdateUserAccountSuccess());
      }).catchError((e) {
        emit(UpdateUserAccountError(e));
      });
    });
  }
}
