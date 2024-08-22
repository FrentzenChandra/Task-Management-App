part of 'employee_bloc.dart';

@immutable
sealed class EmployeeState {}

final class EmployeeInitial extends EmployeeState {}

final class EmployeeLoading extends EmployeeState {}

// berguna untuk melakukan sebuah class dan menerima parameter custom
// yaitu message untuk info gagal pengambilan data
final class EmployeeFailed extends EmployeeState {
  final String message;

  EmployeeFailed(this.message);
}

// calss yang menerima parameter data employees 
final class EmployeeLoaded extends EmployeeState {
  final List<User> employees;

  EmployeeLoaded(this.employees);
}
