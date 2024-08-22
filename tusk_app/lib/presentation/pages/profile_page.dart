import 'package:tusk_app/common/app_color.dart';
import 'package:tusk_app/common/app_route.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:tusk_app/presentation/bloc/user/user_cubit.dart';
import 'package:d_info/d_info.dart';
import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          appBar(),
          header(),
          const Gap(40),
          buildItemMenu(Icons.edit, 'Edit Profile'),
          const Gap(16),
          buildItemMenu(Icons.settings, 'Settings'),
          const Gap(16),
          buildItemMenu(Icons.feedback, 'Feedback'),
          const Gap(16),
          buildItemMenu(Icons.lock, 'Update Password'),
          const Gap(16),
          buildItemMenu(Icons.logout, 'Logout', () {
            DInfo.dialogConfirmation(
              context,
              "Logout",
              'Yes to confirm logout',
            ).then((yes) {
              if (yes ?? false) {
                // kita akan menghapus session yang menampung info info
                // akun kita pada DSession / session
                DSession.removeUser();
                // setelah itu kita update agar di context kita memiliki
                // data yang kosong
                context.read<UserCubit>().update(User());
                // hapus dann pindah page loginp
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.login,
                  (route) => route.settings.name == AppRoute.home,
                );
              }
            });
          }),
          const Gap(30),
        ],
      ),
    );
  }

  Widget buildItemMenu(IconData icon, String title, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColor.primary,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColor.textTitle,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.navigate_next,
              color: AppColor.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Stack(
      children: [
        Container(
          height: 140,
          color: AppColor.primary,
          margin: const EdgeInsets.only(bottom: 60),
        ),
        Positioned(
          top: 60,
          left: 30,
          right: 30,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<UserCubit, User>(
              // penggunaan cubit untuk mengubah data pada header
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      // untuk mengubah nama
                      state.name ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.textTitle,
                        fontSize: 18,
                      ),
                    ),
                    const Gap(6),
                    // mengubah email
                    Text(
                      state.email ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: AppColor.textBody,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // Box shadow berguna untuk membuat shadow
              // atau bayangan di sini kita membuatnya
              // untuk gambar profile kita
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black38,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                'assets/profile.png',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text('Profile'),
      centerTitle: true,
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BackButton(color: Colors.white),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
