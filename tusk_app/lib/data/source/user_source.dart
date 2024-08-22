import 'dart:convert';

import 'package:d_method/d_method.dart';
import 'package:tusk_app/common/urls.dart';
import 'package:tusk_app/data/models/user.dart';
import 'package:http/http.dart' as http;

class UserSource {
  // Membuat base url untuk menembak api user
  // jadi artinya isi _baseUrl = 'http://192.168.18.5:9090/users'
  static const _baseURL = '${URLs.host}/users';

  // membuat sebuah function async (teratur / berurutan) untuk login yang dimana
  // meminta paramter email dan password untuk login
  static Future<User?> login(String email, String password) async {
    try {
      // menyimpan response dari login ke response
      // dari hasil tembak api
      // untuk await ini gunanya agar code yang await diselesaikan dulu
      // sebelum menjalankan code yang lain
      final response = await http.post(
        // tujuan api yang ingin di tembak / request
        Uri.parse('$_baseURL/login'),
        // jadi isi dari body / inputan user untuk membuat request itu
        // digunakan disini object yang dikirim juga
        // bedasarkan dari api body
        body: jsonEncode({'email': email, 'password': password}),
      );

      // berguna untuk melihat isi response menggunakan log
      DMethod.logResponse(response);

      // jika status code yang diterima adalah 200 (berhasil) maka
      // hasil dari response body (json) akan kita masukan ke dalam map
      // map kurang lebih sama dengan object
      // lalu kita kembalikan hasil data nya dengan tipe map<string , dinamic>
      // dynamic ini tipe data yang bisa berubah contoh nya
      //jika ada data bertipe string lalu diubah ke integer maka dinamic
      // akan memperbolehkan hal tersebut https://gepcode.com/post/pemrograman-dart-tipe-data
      if (response.statusCode == 200) {
        Map resBody = jsonDecode(response.body);
        return User.fromJson(Map.from(resBody));
      }

      //catch digunakan jika terjadi error pada function kita
    } catch (e) {
      // akan di print menggunakan log
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<(bool, String)> addEmployee(
      String name, String email, String password) async {
    try {
      final response = await http.post(Uri.parse('$_baseURL'),
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }));

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        Map resBody = jsonDecode(response.body);
        return (true, "Success Add New Employee");
      } else if (response.statusCode == 500) {
        return (false, "Email Already Exist");
      }

      return (false, "Failed Add New Employee");
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return (false, "Something went wrong");
    }
  }

// mereturn sebuah bool dengan paramter yang diterima integer id sebagai userId
  static Future<bool> DeleteEmployee(int id) async {
    try {
      // melakukan request api dengan method delete
      final response = await http.delete(Uri.parse('$_baseURL/$id'));

      // logging
      DMethod.logResponse(response);

      // return apakah status code nya 200 = true / false
      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<List<User>?> getEmployee() async {
    try {
      // melakukan request api dengan method get menampung response nya
      final response = await http.get(Uri.parse('$_baseURL/Employee'));

      // logging
      DMethod.logResponse(response);

      // setelah itu cek apakah berhasil
      if (response.statusCode == 200) {
        // decode response dari response api yang kita buat sebelum nya
        // menggunakan golang kita sadar bahwa itu adalah array / list of user
        // jadi pertama kita hanya akan menggambil dia dalam bentuk list / array
        List resBody = jsonDecode(response.body);
        // kemudian
        List<User> users =
            resBody.map((e) => User.fromJson(Map.from(e))).toList();
        //kemudian yang ini contoh nya itu
        // e akan melakukan cek isi array 1 per satu
        // misal e array pertama isi nya user{"name" : "toto" }
        // lalu masukan e tersebut ke dalam bentuk user
        // begitu juga dengan yang selanjut nya ke 2 , 3 , 4 sampai habis
        // lalu masukan satu per satu ke dalam map dan setelah itu dibuat lah list of user

        return users;
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }
}
