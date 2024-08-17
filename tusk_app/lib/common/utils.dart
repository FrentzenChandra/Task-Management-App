import 'package:intl/intl.dart';
import 'package:tusk_app/data/models/task.dart';

// Untuk mengambil data bedasarkan task status
String dateByStatus(Task task) {
  switch (task.status) {
    case 'Queue':
      return _formatDateTime1(task.createdAt!);
    case 'Review':
      return _formatDateTime1(task.submitDate!);
    case 'Approved':
      return _formatDateTime1(task.approvedDate!);
    case 'Rejected':
      return _formatDateTime1(task.rejectedDate!);
    default:
      return "-";
  }
}

// Untuk mengkonvert date time menjadi dateformat yang digunakan
// di bagian database
String _formatDateTime1(DateTime dateTime) {
  return DateFormat('d MMM yyyy, HH:mm').format(dateTime);
}

// Mengambil gambar icon bedasarkan task status
String iconByStatus(Task task) {
  switch (task.status) {
    case 'Review':
      return "assets/review_icon.png";
    case 'Approved':
      return "assets/approved_icon.png";
    case 'Rejected':
      return "assets/rejected_icon.png";
    default:
      return "assets/queue_icon.png";
  }
}
