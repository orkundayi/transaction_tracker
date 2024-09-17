import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'update_user_account_event.dart';
part 'update_user_account_state.dart';

class UpdateUserAccountBloc extends Bloc<UpdateUserAccountEvent, UpdateUserAccountState> {
  UpdateUserAccountBloc() : super(UpdateUserAccountInitial()) {
    on<UpdateUserAccountEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
