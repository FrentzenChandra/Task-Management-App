import 'package:tusk_app/data/models/task.dart';
import 'package:tusk_app/data/source/task_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'progress_task_event.dart';
part 'progress_task_state.dart';

class ProgressTaskBloc extends Bloc<ProgressTaskEvent, ProgressTaskState> {
  ProgressTaskBloc() : super(ProgressTaskInitial()) {
    on<OnFetchProgressTasks>((event, emit) async {
      emit(ProgressTaskLoading());
      List<Task>? result = await TaskSource.progress(event.userId);
      if (result == null) {
        emit(ProgressTaskFailed("Something went wrong"));
      } else {
        emit(ProgressTaskLoaded(result));
      }
    });
  }
}
