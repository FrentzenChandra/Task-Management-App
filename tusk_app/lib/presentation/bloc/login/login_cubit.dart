import 'package:bloc/bloc.dart';
import 'package:d_session/d_session.dart';
import 'package:meta/meta.dart';
import 'package:tusk_app/common/enums.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/data/source/user_source.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(null, RequestStatus.init));

  clickLogin(String email, String password) async {
    // menembak api menggunakan source User
    User? result = await UserSource.login(email, password);

    if (result == null) {
      // memberikan pemberitahuan jika Gagal
      emit(LoginState(null, RequestStatus.failed));
    } else {
      // menyimpan session dari hasil tembaik api menggunakan User source
      // lalu dari json di assign ke DSession
      DSession.setUser(result.toJson());
      // memberikan pemberitahuan jika berhasil
      emit(LoginState(result, RequestStatus.success));
    }
  }
}
