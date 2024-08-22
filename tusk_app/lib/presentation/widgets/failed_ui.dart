// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:tusk_app/common/app_color.dart';

// sebuah class yang berguna untuk menampilkan
// tampilan failed atau gagal yang bisa di custom
class FailedUI extends StatelessWidget {
  const FailedUI({
    Key? key,
    this.icon,
    required this.message,
    this.margin,
  }) : super(key: key);
  // kita dapat mengirimkan icon , message dan juga margin custom
  final IconData? icon;
  final String message;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        margin: margin, //custom margin
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error, // custom icon
              color: Colors.grey, // custom color
              size: 30,
            ),
            const Gap(20),
            Text(
              message,
              style: TextStyle(color: AppColor.textBody),
            ),
          ],
        ),
      ),
    );
  }
}
