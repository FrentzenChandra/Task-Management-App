import 'package:tusk_app/common/app_color.dart';
import 'package:tusk_app/common/app_info.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/data/source/task_source.dart';
import 'package:tusk_app/presentation/widgets/app_button.dart';
import 'package:d_button/d_button.dart';
import 'package:d_input/d_input.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key, required this.employee});
  final User employee;

// jalankan page _addTaskPageState
  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final dueDate = DateTime.now().obs;
  final edtTitle = TextEditingController();
  final edtDescription = TextEditingController();

  // function date yang berguna untuk mengubah waktu
  // dan juga menampilkan waktu
  pickDueDate() {
    try {
      // mengambil waktu
      showDatePicker(
        context: context,
        // jangka pemilihan waktu awal
        firstDate: DateTime.now(),
        // jangka pemilihan waktu akhir
        lastDate: DateTime.now().add(const Duration(days: 90)),
      ).then((pickedDate) {
        if (pickedDate == null) return;
        // jika tidak memilihi tetapkan waktu sekarang untuk di display
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((pickedTime) {
          // jika waktu dipilih kosong berhenti
          if (pickedTime == null) return;
          // menampilkan waktu tengah format sekian
          dueDate.value = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      });
      // error handling
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
    }
  }

  // function untuk mengaktifkan source
  // menambahkan yang dimana menambahkan
  // data ke database secara tidak langsung
  addNewTask() {
    if (edtTitle.text == "") return;
    if (edtDescription.text == "") return;
    TaskSource.add(
      edtTitle.text,
      edtDescription.text,
      dueDate.value.toIso8601String(),
      widget.employee.id!,
    ).then((success) {
      // jika task Source selesai dilakukan maka
      if (success) {
        AppInfo.success(context,
            "Success Add new Task"); // jika sukses maka tampilkan info sukses
      } else {
        AppInfo.failed(context,
            "Failed Add new Task"); // jika selain sukses tampilkan info gagal
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Task'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DInput(
            controller: edtTitle,
            title: 'Title',
            hint: 'type...',
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          DInput(
            controller: edtDescription,
            title: 'Description',
            hint: 'type...',
            minLine: 5,
            maxLine: 5,
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          Row(
            children: [
              DButtonBorder(
                onClick: () => pickDueDate(),
                radius: 8,
                borderColor: AppColor.primary,
                child: const Text('Due Date'),
              ),
              const Gap(16),
              Obx(() {
                return Text(
                  DateFormat('d MMM yyyy, HH:mm').format(dueDate.value),
                );
              }),
            ],
          ),
          const Gap(20),
          AppButton.primary(
            'Add Task',
            () => addNewTask(),
          ),
        ],
      ),
    );
  }
}
