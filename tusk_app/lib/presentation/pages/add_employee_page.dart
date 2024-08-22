import 'package:d_input/d_input.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:tusk_app/common/app_info.dart';
import 'package:tusk_app/data/source/user_source.dart';
import 'package:tusk_app/presentation/widgets/app_button.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  // membuat sebuah input yang akan digunakan
  // untuk mengambil data dan mengassign inputan
  final edtName = TextEditingController();
  final edtEmail = TextEditingController();
  final edtPassword = TextEditingController();

  addNewEmployee() {
    // tembak api menggunakan source
    UserSource.addEmployee(edtName.text, edtEmail.text, edtPassword.text)
        .then((value) {
      // lalu hasil nya akan digunakan
      var (bool success, String message) = value;
      if (success) {
        AppInfo.success(context, message); // untuk memberikan info
      } else {
        AppInfo.failed(context, message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('New Employee'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // input yang di assign ke dalam variabel edtName
          DInput(
            controller: edtName,
            title: 'Name',
            hint: 'type name...',
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          // input yang di assign ke dalam variabel edtEmail
          DInput(
            controller: edtEmail,
            title: 'Email',
            hint: 'type email...',
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          // input yang di assign ke dalam variabel edtPassword
          DInputPassword(
            controller: edtPassword,
            title: 'Password',
            hint: 'type password...',
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          // memanggil widget yang sebelumnya kita buat lalu menjalankan
          // api yang kita gunakan untuk menambah akun employee
          AppButton.primary('Add', () => addNewEmployee()),
        ],
      ),
    );
  }
}
