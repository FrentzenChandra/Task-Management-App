import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/data/source/user_source.dart';

part 'employee_event.dart';
part 'employee_state.dart';
// membuat sebuah bloc dimana berguna untuk menembak
// api dan juga melakukan emit pada data nya
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  EmployeeBloc() : super(EmployeeInitial()) {
    on<OnFetchEmployee>((event, emit) async {
      emit(EmployeeLoading()); // perspiakan emit untuk menerima sebuah data
      List<User>? result = await UserSource.getEmployee(); // menembak api lalu mendapatkan hasil api tersebut
      if (result == null) {
        emit(EmployeeFailed('Something wrong')); // hasil jika data tidak ada isinya
      } else {
        emit(EmployeeLoaded(result));  // hasil jika sukses
      }
    });
  }
}
