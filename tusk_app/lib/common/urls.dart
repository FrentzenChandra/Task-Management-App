// Membuat sebuah url dan juga function untuk mengabungkan api dengan
// path file nya
class URLs {
  static const host = 'http://192.168.18.5:9090';
  static String image(String fileName) => '$host/attachments/$fileName';
}
