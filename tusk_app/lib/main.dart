import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tusk_app/common/app_color.dart';
import 'package:tusk_app/common/app_route.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/presentation/bloc/detail_task/detail_task_cubit.dart';
import 'package:tusk_app/presentation/bloc/employee/employee_bloc.dart';
import 'package:tusk_app/presentation/bloc/list_task/list_task_bloc.dart';
import 'package:tusk_app/presentation/bloc/login/login_cubit.dart';
import 'package:tusk_app/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:tusk_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:tusk_app/presentation/bloc/stat_employee/stat_employee_cubit.dart';
import 'package:tusk_app/presentation/pages/add_employee_page.dart';
import 'package:tusk_app/presentation/pages/add_task_page.dart';
import 'package:tusk_app/presentation/pages/detail_task_page.dart';
import 'package:tusk_app/presentation/pages/home_admin_page.dart';
import 'package:tusk_app/presentation/pages/home_employee_page.dart';
import 'package:tusk_app/presentation/pages/list_task_page.dart';
import 'package:tusk_app/presentation/pages/login_page.dart';
import 'package:tusk_app/presentation/bloc/user/user_cubit.dart';
import 'package:tusk_app/presentation/pages/monitor_employee_page.dart';
import 'package:tusk_app/presentation/pages/profile_page.dart';

void main() {
  // Mengasign plugin widgetFlutterBinding
  WidgetsFlutterBinding.ensureInitialized();
  // berguna untuk menunggu agar flutter mengsetting
  // dengan orientasi potrait up lalu
  // aplikasi di jalankan
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => StatEmployeeCubit()),
        BlocProvider(create: (context) => DetailTaskCubit()),
        BlocProvider(create: (context) => ProgressTaskBloc()),
        BlocProvider(create: (context) => NeedReviewBloc()),
        BlocProvider(create: (context) => EmployeeBloc()),
        BlocProvider(create: (context) => ListTaskBloc()),
      ],
      child: MaterialApp(
        // Untuk menghilangkan mode Banner di debug
        debugShowCheckedModeBanner: false,
        // Untuk mengatur tema
        theme: ThemeData.light(useMaterial3: true).copyWith(
          // menganti warna utama menjadi isi dari variael AppColor.primary
          primaryColor: AppColor.primary,
          // mengubbah color scheme
          colorScheme: ColorScheme.light(
            primary: AppColor.primary,
            secondary: AppColor.secondary,
          ),
          // mengubah warna background scaffolding
          scaffoldBackgroundColor: AppColor.scaffold,
          // mengubah font style
          textTheme: GoogleFonts.poppinsTextTheme(),
          // mengubah tema bar dengan warna dan text yang bereda
          appBarTheme: AppBarTheme(
            surfaceTintColor: AppColor.primary,
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          //Menguah warna theme popup
          popupMenuTheme: const PopupMenuThemeData(
              color: Colors.white, surfaceTintColor: Colors.white),
          // mengubah warna background dan surface tintcolor
          dialogTheme: const DialogTheme(
              surfaceTintColor: Colors.white, backgroundColor: Colors.white),
        ),
        // route pertama yang ditunjukan
        initialRoute: AppRoute.home,
        routes: {
          AppRoute.home: ((context) {
            return FutureBuilder(
                future: DSession.getUser(),
                builder: (context, snapshot) {
                  // melihat apakah data ada di snapshot
                  // jika tidak ada kemalikan ke page login
                  if (snapshot.data == null) return const loginPage(); // login
                  // mengkonvert json ke yang ada di snapshot.data
                  // lalu di masukan ke variabel user yang memiliki tipe data User
                  User user = User.fromJson(Map.from(snapshot.data!));
                  // memanggil function update yang dimana
                  // digunakan untuk mengupdate data yang ada di variabel user
                  // yang dimana variabel tersebut diupdate bedasarkan apa yang ada
                  // di context
                  context.read<UserCubit>().update(user);
                  // scaffold nanti akan diubah untuk mengkondisikan
                  // tergantu role yang login
                  if (user.role == "Admin")
                    return const HomeAdminPage(); // homepage admin
                  return const HomeEmployePage(); // homepage Employee
                });
          }),
          // Memuat routing yang nanti function return nya (scaffold) akan diganti
          // oleh function yang digunakan pada routing masing masing
          AppRoute.addEmployee: (context) => const AddEmployeePage(),
          AppRoute.addTask: (context) {
            User employee = ModalRoute.of(context)!.settings.arguments as User;
            return AddTaskPage(employee: employee);
          },
          // detailtask
          AppRoute.detailTask: (context) {
            // akan diberikan argument id untuk digunakan pada detailtask
            int id = ModalRoute.of(context)!.settings.arguments as int;
            return BlocProvider(
              // lalu context harus kita alihkan ke detailTaskCubit
              create: (context) => DetailTaskCubit(),
              // dan juga kita masukkan design kita beserta data id 
              child: DetailTaskPage(id: id),
            );
          },
          AppRoute.listTask: (context) {
            Map data = ModalRoute.of(context)!.settings.arguments as Map;
            return BlocProvider(
              create: (context) => ListTaskBloc(),
              child: ListTaskPage(
                status: data['status'],
                employee: data['employee'],
              ),
            );
          },
          AppRoute.login: (context) => const loginPage(),
          AppRoute.monitorEmployee: (context) {
            // kita membuat seperti ini dikarenakan dalam monitorEmployee itu
            // memerlukan / required argument id yang dalam hal ini kita menyetting
            // untuk hasil argument yang dieberikan di masukan ke dalam variabel user
            // yang dimana akan di teruskan ke dalam MonitorEmployeePage
            // untuk context Tersebut berguna untuk melihat page kita berada sebelum page MonitorEmployeePage
            User employee = ModalRoute.of(context)!.settings.arguments as User;
            return MonitorEmployeePage(employee: employee);
          },
          AppRoute.profile: (context) => const ProfilePage(),
        },
      ),
    );
  }
}
