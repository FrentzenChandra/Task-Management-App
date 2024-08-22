import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:tusk_app/common/app_color.dart';

class AppButton {
  static Widget primary(String title, VoidCallback? onClick) {
    return DButtonFlat(
        onClick: onClick, // pada saat di klik terjadi function
        height: 46, // Tinggi
        mainColor: AppColor.primary, // Warna background DButton
        radius: 12, // radius Corner untuk menumpulkan corner
        child: Text(
          title, // text
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ));
  }
}