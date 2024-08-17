import 'package:flutter/material.dart';
import 'app_color.dart';

// Membuat sebuah object yang berisi sebuah function yang dimana
// akan digunakan untuk memunculkan sebuah snackbar
// atau bisa dibilang pesan lewat
class AppInfo {
  static success(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.approved,
      ),
    );
  }

  static failed(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.rejected,
      ),
    );
  }
}
