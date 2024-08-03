import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

Future<File> downloadFile(String url, String filename) async {
  final response = await http.get(Uri.parse(url));
  final directory = await getApplicationDocumentsDirectory();

  // Ensure the directory exists
  final fileDirectory = Directory('${directory.path}/${filename.split('/').first}');
  if (!await fileDirectory.exists()) {
    await fileDirectory.create(recursive: true);
  }

  final file = File('${directory.path}/$filename');
  print('Downloading file to: ${file.path}'); // Log file path for debugging
  await file.writeAsBytes(response.bodyBytes);

  // Verify if the file exists and its size
  print('File downloaded: ${await file.exists()}');
  print('File size: ${await file.length()} bytes');

  return file;
}

Future<String> getFilePath(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/$filename';
}
