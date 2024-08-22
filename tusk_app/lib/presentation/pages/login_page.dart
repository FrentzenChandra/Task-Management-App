import 'package:d_input/d_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:tusk_app/common/app_color.dart';
import 'package:tusk_app/common/app_info.dart';
import 'package:tusk_app/common/app_route.dart';
import 'package:tusk_app/common/enums.dart';
import 'package:tusk_app/presentation/bloc/login/login_cubit.dart';
import 'package:tusk_app/presentation/bloc/user/user_cubit.dart';
import 'package:tusk_app/presentation/widgets/app_button.dart';

class loginPage extends StatelessWidget {
  const loginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final edtEmail = TextEditingController();
    final edtPassword = TextEditingController();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          buildHeader(), // Untuk membuat Header
          const SizedBox(
              height:
                  40), // Untuk membuat box yang digunakan untuk membuat jarak
          // Padding widget digunakan untuk memberikan jarak antara widget-widget di dalam Column.
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // DInput adalah widget yang menampilkan input teks biasa.
                DInput(
                  controller:
                      edtEmail, // Controller yang digunakan untuk menangani input teks.
                  fillColor: Colors.white, // Warna latar belakang widget.
                  hint: "Email", // Teks yang muncul sebagai petunjuk input.
                  radius: BorderRadius.circular(12), // Radius sudut widget.
                ),
                const SizedBox(
                    height:
                        20), // Widget yang digunakan untuk membuat jarak vertikal.

                // DInputPassword adalah widget yang menampilkan input teks password.
                DInputPassword(
                  controller:
                      edtPassword, // Controller yang digunakan untuk menangani input password.
                  fillColor: Colors.white, // Warna latar belakang widget.
                  hint: "Password", // Teks yang muncul sebagai petunjuk input.
                  radius: BorderRadius.circular(12), // Radius sudut widget.
                ),
                const SizedBox(height: 20), // jarak
                BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    // memeberikan notifikasi bahwa login gagal jika mendapatkan
                    // status gagal dalam state dari loginCubit
                    if (state.requestStatus == RequestStatus.failed) {
                      AppInfo.failed(context, 'Login Failed');
                    }

                    if (state.requestStatus == RequestStatus.success) {
                      // memeberikan notifikasi bahwa login berhasil jika mendapatkan
                      // status berhasil dalam state dari loginCubit
                      AppInfo.success(context, 'Login Success');
                      // berunga untuk mengubah page
                      Navigator.pushNamed(context, AppRoute.home);
                    }
                  },
                  builder: (context, state) {
                    if (state.requestStatus == RequestStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return AppButton.primary("Login", () {
                      context
                          .read<LoginCubit>()
                          .clickLogin(edtEmail.text, edtPassword.text);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AspectRatio buildHeader() {
    return
        // AspectRatio widget digunakan untuk membuat widget mengikuti rasio tertentu.
        // Rasio ini diatur ke 0.9, yang berarti lebarnya adalah 90% dari tingginya.
        AspectRatio(
      aspectRatio: 0.9,
      child: Stack(
        fit: StackFit
            .expand, // Stack akan menyesuaikan ukurannya dengan area yang tersedia.
        children: [
          Positioned.fill(
            bottom: 80, // Gambar akan ditempatkan di bagian bawah stack.
            child: Image.asset(
              'assets/login_bg.png',
              fit: BoxFit.cover, // Gambar akan menutupi seluruh area.
            ),
          ),
          Positioned.fill(
            top: 200, // Gradien akan dimulai di bagian atas stack.
            bottom: 80, // Gradien akan berakhir di bagian bawah stack.
            child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment
                          .bottomCenter, // Gradien dimulai dari tengah bawah.
                      end: Alignment
                          .topCenter, // Gradien berakhir di tengah atas.
                      colors: [
                    AppColor.scaffold,
                    Colors.transparent
                  ] // Warna gradien.
                      )),
            ),
          ),
          Positioned(
            left: 30, // Baris akan ditempatkan 20 piksel dari kiri.
            right: 30, // Baris akan ditempatkan 20 piksel dari kanan.
            bottom: 0, // Baris akan ditempatkan di bagian bawah stack.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .end, // Anak-anak baris akan diatur di bagian bawah.
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  height: 120, // Tinggi gambar logo.
                  width: 120, // Lebar gambar logo.
                ),
                const SizedBox(width: 20), // Spasi 20 piksel.
                RichText(
                  text: TextSpan(
                    text: "Monitoring \n", // Bagian pertama teks.
                    style: TextStyle(
                      color: AppColor.defaultText, // Warna teks.
                      fontSize: 30, // Ukuran teks.
                      height: 1.4, // Ketinggian baris.
                    ),
                    children: [
                      TextSpan(text: 'dengan'), // Bagian kedua teks.
                      TextSpan(
                          text: ' Tusk', // Bagian ketiga teks.
                          style: TextStyle(
                              fontWeight: FontWeight
                                  .bold) // Bagian ketiga teks akan tebal.
                          )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
