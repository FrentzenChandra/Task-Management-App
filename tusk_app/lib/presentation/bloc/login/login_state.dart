part of 'login_cubit.dart';

@immutable
class LoginState {
  final User? user;
  final RequestStatus requestStatus;

  LoginState(this.user, this.requestStatus);
}
