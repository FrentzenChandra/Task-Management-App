part of 'employee_bloc.dart';

// hanya di buat dan akan di gunakan dalam 'employee_bloc.dart'
@immutable
sealed class EmployeeEvent {}

class OnFetchEmployee extends EmployeeEvent {}
