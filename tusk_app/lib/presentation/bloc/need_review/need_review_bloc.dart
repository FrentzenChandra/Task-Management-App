import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tusk_app/common/enums.dart';
import 'package:tusk_app/data/models/task.dart';
import 'package:tusk_app/data/source/task_source.dart';

part 'need_review_event.dart';
part 'need_review_state.dart';

class NeedReviewBloc extends Bloc<NeedReviewEvent, NeedReviewState> {
  NeedReviewBloc() : super(NeedReviewState.init()) {
    on<NeedReviewEvent>((event, emit) async {
      emit(NeedReviewState(RequestStatus.loading, []));

      // tembak api
      final result = await TaskSource.needToBeReview();

      // pengembalian hasil jika isi kosong
      if (result == null) {
        emit(NeedReviewState(RequestStatus.failed, []));
      } else {
        emit(NeedReviewState(RequestStatus.success, result));
      }
    });
  }
}
