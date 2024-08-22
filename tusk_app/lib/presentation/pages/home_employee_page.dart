import 'package:tusk_app/common/app_color.dart';
import 'package:tusk_app/common/app_route.dart';
import 'package:tusk_app/common/utils.dart';
import 'package:tusk_app/data/models/task.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:tusk_app/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:tusk_app/presentation/bloc/user/user_cubit.dart';
import 'package:tusk_app/presentation/widgets/failed_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeEmployePage extends StatefulWidget {
  const HomeEmployePage({super.key});

  @override
  State<HomeEmployePage> createState() => _HomeEmployePageState();
}

class _HomeEmployePageState extends State<HomeEmployePage> {
  late User user;

  // refresh
  refresh() {
    context.read<StatEmployeeCubit>().fetcStatistic(user.id!); // berguna untuk mengambil data statistic status
    context.read<ProgressTaskBloc>().add(OnFetchProgressTasks(user.id!)); // untuk mengamil data task yang selain queque dan review bukan 0
  }

  @override
  void initState() {
    user = context.read<UserCubit>().state;
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColor.primary,
            height: 150,
          ),
          RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Gap(40),
                buildHeader(),
                const Gap(24),
                buildSearch(),
                const Gap(40),
                buildTaskMenu(),
                const Gap(40),
                buildProgressTask(),
                const Gap(20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressTask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Tasks',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            color: AppColor.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(20),
        BlocBuilder<ProgressTaskBloc, ProgressTaskState>(
          builder: (context, state) {
            if (state is ProgressTaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProgressTaskFailed) {
              return FailedUI(message: state.message);
            }
            if (state is ProgressTaskLoaded) {
              List<Task> tasks = state.tasks;
              if (tasks.isEmpty) {
                return const FailedUI(
                  icon: Icons.list,
                  message: "There is no progress",
                );
              }

              return ListView.builder(
                itemCount: tasks.length,
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Task task = tasks[index];
                  return buildItemProgressTasks(task);
                },
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget buildItemProgressTasks(Task task) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoute.detailTask,
          arguments: task.id,
        ).then((value) => refresh());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        height: 80,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 6,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            const Gap(24),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    dateByStatus(task),
                    style: TextStyle(
                      color: AppColor.textBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              iconByStatus(task),
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget buildTaskMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasks',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            color: AppColor.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(20),
        BlocBuilder<StatEmployeeCubit, Map>(
          builder: (context, state) {
            return GridView.count(
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                // memanggil function 4 menu tombol untuk melihat
                // task yang memiliki status yang berbeda beda
                builItemTaskMenu(
                    'assets/queue_bg.png', 'Queue', state['Queue']),
                builItemTaskMenu(
                    'assets/review_bg.png', 'Review', state['Review']),
                builItemTaskMenu(
                    'assets/approved_bg.png', 'Approved', state['Approved']),
                builItemTaskMenu(
                    'assets/rejected_bg.png', 'Rejected', state['Rejected']),
              ],
            );
          },
        )
      ],
    );
  }

  Widget builItemTaskMenu(String asset, String status, int total) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.listTask, arguments: {
          'status': status,
          'employee': user,
        }).then((value) => refresh());
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(asset),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const Gap(6),
            Text(
              '$total tasks',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton( // disini kita membuat sebuah icon button
          // yang dapat dipencet namun belum ada fungsi
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: AppColor.defaultText,
            ),
          ),
          Expanded(
            // membuat text field yang dimana dilakukan expand
            // atau memenuhi width yang tersisa
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search task...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColor.defaultText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoute.profile);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/profile.png',
              height: 40,
              width: 40,
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello,',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              BlocBuilder<UserCubit, User>(
                builder: (context, state) {
                  return Text(
                    state.name ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          child: Text(
            DateFormat('d MMMM, yyyy').format(DateTime.now()),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
