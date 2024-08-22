import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tusk_app/common/app_color.dart';
import 'package:gap/gap.dart';
import 'package:tusk_app/common/app_info.dart';
import 'package:tusk_app/common/app_route.dart';
import 'package:tusk_app/common/enums.dart';
import 'package:tusk_app/data/models/task.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/data/source/user_source.dart';
import 'package:tusk_app/presentation/bloc/employee/employee_bloc.dart';
import 'package:tusk_app/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:tusk_app/presentation/bloc/user/user_cubit.dart';
import 'package:tusk_app/presentation/widgets/failed_ui.dart';
import 'package:d_info/d_info.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  getNeedReview() {
    // mengambil data ke source dan masukkan ke dalam context
    context.read<NeedReviewBloc>().add(OnFetchNeedReview());
  }

  getEmployee() {
    // menambahkan isi dari context dengan mengambil data employee
    context.read<EmployeeBloc>().add(OnFetchEmployee());
  }

  deleteEmployee(User employee) {
    // digunakan untuk mengkonfirmasikan
    DInfo.dialogConfirmation(
      context,
      'Delete',
      'Yes to confirm',
    ).then((bool? yes) {
      // jika false maka lewati function yang ada di dalam
      if (yes ?? false) {
        // jika true maka lanjut ke proses penghaspusan
        UserSource.DeleteEmployee(employee.id!).then((success) {
          if (success) {
            AppInfo.success(context, 'Success Delete');
            getEmployee();
          } else {
            AppInfo.failed(context, 'Failed Delete');
          }
        });
      }
    });
  }

// refresh berguna untuk mengambil data lagi yang sudah diuah
  refresh() {
    getNeedReview();
    getEmployee();
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // panggil Function header
          Stack(
            children: [
              buildHeader(),
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                child: buildAddEmployeeButton(),
              )
            ],
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Gap(20),
                buildNewReview(),
                Gap(20),
                buildEmployee(),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget buildEmployee() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employee',
          style: GoogleFonts.montserrat(
            color: AppColor.textTitle,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            if (state is EmployeeLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is EmployeeFailed) {
              return const FailedUI(
                margin: EdgeInsets.only(top: 20),
                message: 'Something wrong',
              );
            }
            if (state is EmployeeLoaded) {
              List<User> employees = state.employees;
              if (employees.isEmpty) {
                return const FailedUI(
                  margin: EdgeInsets.only(top: 20),
                  icon: Icons.list,
                  message: 'There is no employee',
                );
              }
              // list View Build digunakan untuk menghasilkan
              // sebuah list yang berulang
              return ListView.builder(
                itemCount: employees.length, // berapa banyak item
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  User employee = employees[index];
                  return buildItemEmployee(employee);
                },
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget buildItemEmployee(User employee) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 6,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              'assets/profile.png',
              width: 40,
              height: 40,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              // masukan data nama
              employee.name ?? '',
              // hanya boleh 1 baris
              maxLines: 1,
              // berikan ... jika text melebihi container / parent
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColor.textTitle,
              ),
            ),
          ),
          // digunakan untuk menampilkan sebuah titik 3 / tombol untuk detail
          PopupMenuButton(
            // pada saat pilihan di klik
            onSelected: (value) {
              // jika pilihan yang diklik monitor
              if (value == 'Monitor') {
                // pergi ke page monitorEmployee
                Navigator.pushNamed(
                  context, // dengan data  yang ada dikonteks
                  AppRoute.monitorEmployee,
                  arguments: employee, // dan argumen employee / user
                ).then((value) => refresh()); // lalu refresh
              }
              if (value == 'Delete') {
                deleteEmployee(employee);
              }
            },
            // disini kita membuat isi dari icon detail jika di pencet
            // memerlukan sebuah parameter context
            itemBuilder: (context) => ['Monitor', 'Delete'].map((e) {
              return PopupMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildNewReview() {
    // oke disini kita membuat komponen untuk membuat tampilan task yang harus di review
    // beserta data nya
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Need To be Review',
        style: GoogleFonts.montserrat(
          color: AppColor.textTitle,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // mengambil data beserta response nya
      BlocBuilder<NeedReviewBloc, NeedReviewState>(builder: (context, state) {
        // response jika data masih belum selesai di dapatkan
        if (state.requestStatus == RequestStatus.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // response jika data sudah selesai di dapatkan namun gagal
        if (state.requestStatus == RequestStatus.failed) {
          return FailedUI(
            message: "Something Went Wrong",
            margin: EdgeInsets.only(top: 20),
          );
        }

        // response jika data success
        if (state.requestStatus == RequestStatus.success) {
          List<Task> tasks = state.tasks;
          // namun jika tidak ada
          if (tasks.isEmpty) {
            return FailedUI(
              message: "No Task Need To Be Review",
              icon: Icons.list,
              margin: EdgeInsets.only(top: 20),
            );
          }
          // tampilkan isi data
          return Column(
            // map berguna untuk melakukan pengulangan
            // pada sebuah list / array dan dilakukan sesuatu
            // perisi array nya
            children: tasks.map((e) {
              return buildItemNeedReview(e);
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      })
    ]);
  }

  Widget buildItemNeedReview(Task task) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoute.detailTask,
          arguments: task.id,
        ).then((value) => refresh());
      },
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                "assets/profile.png",
                width: 40,
                height: 40,
              ),
            ),
            const Gap(16),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? "",
                  maxLines: 1,
                  // ini berguna jika sebuah text melebihi parent / container
                  // maka akan diberikan ...
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColor.textTitle,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  task.user?.name ?? "",
                  style: TextStyle(
                    color: AppColor.textBody,
                    fontSize: 12,
                  ),
                ),
              ],
            )),
            const Icon(
              Icons.navigate_next,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      height: 160,
      margin: EdgeInsets.only(bottom: 20),
      color: AppColor.primary,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      alignment: Alignment.topCenter,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // gesture pada saat di tap
          GestureDetector(
            onTap: () {
              // ganti page profile
              Navigator.pushNamed(context, AppRoute.profile)
                  .then((val) => {refresh()});
            },
            child: ClipRRect(
              // diberikan radius agar bulat
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                "assets/profile.png",
                height: 40,
                width: 40,
              ),
            ),
          ),
          // berikan jarak
          Gap(16),
          // expanded untuk mengisi jarak yang ada
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mengatur tata letak di kiri / start
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                // berguna untuk mengubah text
                // bedasarkan state data
                BlocBuilder<UserCubit, User>(
                  builder: (context, state) {
                    return Text(
                      // mengubah nama jika state.name null maka kosong
                      // jika ada isinya maka gunakan
                      state.name ?? "",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    );
                  },
                )
              ],
            ),
          ),
          // membuat sebuah container
          Container(
            // membuat sebuah box dalam container
            // yang memiliki warna putih dan juga
            // memiliki radius untuk membuat corner nya tumpul
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            // padding untuk jarak kosong di sekitar huruf
            // yang dikustom horizontal dan symetrical nya
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            // text tanggal dengan format sekian
            child: Text(
              DateFormat('d MMMM, yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildAddEmployeeButton() {
    return DButtonElevation(
      onClick: () {
        // ganti page
        Navigator.pushNamed(context, AppRoute.addEmployee)
            .then((value) => {refresh()});
      },
      height: 50,
      radius: 12,
      mainColor: Colors.white,
      elevation: 4,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add),
          Gap(4),
          Text(
            "Add New Employee",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
