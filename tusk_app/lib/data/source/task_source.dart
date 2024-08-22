import 'dart:convert';

import 'package:d_method/d_method.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tusk_app/common/urls.dart';
import 'package:tusk_app/data/models/task.dart';
import 'package:http/http.dart' as http;

class TaskSource {
  // 'http://192.168.18.5:9090/tasks'
  static const _baseURL = '${URLs.host}/tasks';

  static Future<bool> add(
      String title, String desc, String dueDate, int userId) async {
    try {
      // melakukan tembak api dengan body seperti ini
      final response = await http.post(Uri.parse(_baseURL),
          body: jsonEncode({
            "title": title,
            "description": desc,
            "status": "Queue",
            "dueDate": dueDate,
            "userId": userId
          }));

      //log response
      DMethod.logResponse(response);

      // mengembalikan data true / false
      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> delete(int userId) async {
    try {
      // Tembak api dengan method delete tanpa body dengan url 'http://192.168.18.5:9090/tasks/:id'
      final response = await http.delete(Uri.parse('$_baseURL/$userId'));

      DMethod.logResponse(response);
      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> submit(int userId, XFile attachment) async {
    try {
      // membuat sebuah request dengan format multipartRequest
      // karna ada memiliki gambar di dalamnya
      // mengguanakan patch
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$_baseURL/$userId/submit'),
      )
        // untuk mengirimkan form submitdate bersifat string dari waktu
        // sekarang
        ..fields['submitDate'] = DateTime.now().toIso8601String()
        // berguna untuk mengisi form attachment dengan path dan name file
        ..files.add(await http.MultipartFile.fromPath(
          'attachment',
          attachment.path,
          filename: attachment.name,
        ));

      // kirimkan request api / eksekusi request api
      final response = await request.send();
      //log response
      DMethod.log(response.toString());

      // mengembalikan data true / false
      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> reject(int id, String reason) async {
    try {
      // melakukan tembak api dengan body seperti ini
      final response = await http.patch(Uri.parse('$_baseURL/$id/reject'),
          body: {"reason": reason, "rejectedDate": DateTime.now().toString()});

      //log response
      DMethod.logResponse(response);

      // mengembalikan data true / false
      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> fix(int id, int revision) async {
    try {
      // melakukan tembak api dengan body seperti ini
      final response = await http
          .patch(Uri.parse('$_baseURL/$id/fix'), body: {"revision": revision});

      //log response
      DMethod.logResponse(response);

      // mengembalikan data true / false
      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<bool> approve(int taskId) async {
    try {
      final response =
          await http.patch(Uri.parse("$_baseURL/$taskId/approve"), body: {
        "approveDate": DateTime.now().toIso8601String(),
      });

      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }

  static Future<Task?> findById(int taskId) async {
    try {
      final response = await http.get(Uri.parse('$_baseURL/$taskId'));

      DMethod.logResponse(response);

      // jika bberhasil lakukan convert ke map dari json
      // data lalu di buat ke dalam data dalam bentuk task
      if (response.statusCode == 200) {
        Map resBody = jsonDecode(response.body);
        return Task.fromJson(Map.from(resBody));
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> needToBeReview() async {
    try {
      final response = await http.get(Uri.parse('$_baseURL/review/asc'));

      DMethod.logResponse(response);

      // mengkonvert sebuah response json menjadi sebuah
      // list of Task / array of object(task)
      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        List<Task> data =
            resBody.map((e) => Task.fromJson(Map.from(e))).toList();
        return data;
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> progress(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseURL/progress/$id'));

      DMethod.logResponse(response);

      // jadi kurang lebih dalam sini itu dibuat seperti ini
      //  kita harus mengkonver dulu json yang sudah dimarshal (bentuk byte)
      // ke dalam list lalu nilai dari list itu kita iterasi
      // ke dalam sebuah map satu persatu dan setelah itu dikonvert ke task
      // lalu jika semua isi dari list resbody sudah dibuat ke task baru lah
      // baru kita ubah ke dalam list<task>
      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);

        List<Task> data =
            resBody.map((e) => Task.fromJson(Map.from(e))).toList();
        return data;
      }
      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<Map?> statistic(int userId) async {
    List listStatus = ['Queue', 'Review', 'Approved', 'Rejected'];
    Map stat = {};
    try {
      final response = await http.get(Uri.parse("$_baseURL/stat/$userId"));

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);

        // melakukan for of
        for (String status in listStatus) {
          List resBody = jsonDecode(response.body);
          // Mengambil mencari nilai jika ada stat yang tidak ada dalam
          // map maka diberikan status dengan nilai null
          Map? found = resBody.where((e) => e['status'] == status).firstOrNull;
          // mengisi stat yang memiliki status yang berbeda setiap for of
          // masukan nilai total nya jika null maka 0
          stat[status] = found?['total'] ?? 0;
        }
        return stat;
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }

  static Future<List<Task>?> whereUserAndStatus(int id, String stat) async {
    try {
      final response = await http.get(Uri.parse('$_baseURL/user/$id/$stat'));

      DMethod.logResponse(response);

      if (response.statusCode == 200) {
        List resBody = jsonDecode(response.body);
        List<Task> data =
            resBody.map((e) => Task.fromJson(Map.from(e))).toList();
        return data;
      }

      return null;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return null;
    }
  }


  static Future<bool> fixToQueue(int id, int revision) async { // task untuk menganti menjadi queue
    try {
      final response = await http.patch
      ( //url fix
        Uri.parse('$_baseURL/$id/fix'),
        body: {
          // menamahkan revision
          "revision": '$revision',
        },
      );
      DMethod.logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
      return false;
    }
  }
}
