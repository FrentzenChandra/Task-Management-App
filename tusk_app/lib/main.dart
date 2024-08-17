import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tusk_app/common/app_color.dart';
import 'package:tusk_app/common/app_route.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/presentation/bloc/user/user_cubit.dart';

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
                  if (snapshot.data == null) return const Scaffold(); // login
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
                    return const Scaffold(); // homepage admin
                  return const Scaffold(); // homepage Employee
                });
          }),
          // Memuat routing yang nanti function return nya (scaffold) akan diganti
          // oleh function yang digunakan pada routing masing masing
          AppRoute.addEmployee: (context) => const Scaffold(),
          AppRoute.addTask: (context) => const Scaffold(),
          AppRoute.detailTask: (context) => const Scaffold(),
          AppRoute.listTask: (context) => const Scaffold(),
          AppRoute.login: (context) => const Scaffold(),
          AppRoute.monitorEmployee: (context) => const Scaffold(),
          AppRoute.profile: (context) => const Scaffold(),
        },
      ),
    );
  }
}
