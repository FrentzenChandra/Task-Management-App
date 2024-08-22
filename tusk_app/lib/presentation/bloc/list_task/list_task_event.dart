part of 'list_task_bloc.dart';

@immutable
sealed class ListTaskEvent {}

class OnFetchListTask extends ListTaskEvent {
  final String status;
  final int employeeId;

  OnFetchListTask(this.status, this.employeeId);
}
