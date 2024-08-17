import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tusk_app/data/models/user.dart';

class UserCubit extends Cubit<User> {
  UserCubit() : super(User());

  update(User n) => emit(n);
}
