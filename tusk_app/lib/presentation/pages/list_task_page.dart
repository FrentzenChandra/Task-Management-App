import 'package:tusk_app/common/app_color.dart';
import 'package:tusk_app/common/app_route.dart';
import 'package:tusk_app/data/models/task.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/presentation/bloc/list_task/list_task_bloc.dart';
import 'package:tusk_app/presentation/widgets/failed_ui.dart';
import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ListTaskPage extends StatefulWidget {
  const ListTaskPage({
    super.key,
    required this.status,
    required this.employee,
  });
  final String status;
  final User employee;

  @override
  State<ListTaskPage> createState() => _ListTaskPageState();
}

class _ListTaskPageState extends State<ListTaskPage> {
  // digunakan untuk mengulang pemagilan data
  refresh() {
    context.read<ListTaskBloc>().add(
          OnFetchListTask(widget.status, widget.employee.id!),
        );
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  // pemanggilan function untuk membuat / menampilkan
  // tampilan
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          header(),
          Expanded( // expanded berguna agar meghindari error unbound height
            child: buildListTask(),
          ),
        ],
      ),
    );
  }

  Widget buildListTask() {
    //logic button untuk hasil pengambilan data api
    return BlocBuilder<ListTaskBloc, ListTaskState>(
      builder: (context, state) {
        if (state is ListTaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ListTaskFailed) {
          return FailedUI(message: state.message);
        }
        if (state is ListTaskLoaded) {
          List<Task> tasks = state.tasks;
          if (tasks.isEmpty) {
            return const FailedUI(
              message: "There is no task",
              icon: Icons.list,
            );
          }
          // list View untuk membuat list yang berulang
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return buildItemTask(task);
            },
          );
        }
        return const SizedBox.shrink(); // untuk pengembalian/ return widget jika tidak
        // memenuhi segala if / konditional yang dimana
        // sizedBox shrink berguna untuk mengembalikan box
        // yang paling kecil tergantung minimal ukuran terkecil yang parent dapat
        // perbolehkan
      },
    );
  }

  Widget buildItemTask(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event,
                color: Colors.grey,
                size: 18,
              ),
              const Gap(8),
              Text(
                DateFormat('d MMM').format(task.createdAt!),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            task.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColor.textTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(6),
          Text(
            task.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColor.textBody,
              fontSize: 14,
            ),
          ),
          const Gap(20),
          DButtonBorder(
            onClick: () {
              Navigator.pushNamed(
                context,
                AppRoute.detailTask,
                arguments: task.id,
              ).then((value) => refresh());
            },
            mainColor: Colors.white,
            radius: 10,
            borderColor: AppColor.scaffold,
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(20, 50, 20, 4),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 0,
            top: 0,
            child: UnconstrainedBox(
              child: DButtonFlat(
                width: 36,
                height: 36,
                radius: 10,
                mainColor: Colors.white,
                onClick: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            top: 0,
            child: Chip(
              side: BorderSide.none,
              label: Text(
                widget.employee.name ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
