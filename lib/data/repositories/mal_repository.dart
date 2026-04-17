import 'dart:convert';
import 'dart:io';

import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class MALRepository extends BaseRepository {
  MALRepository() : super(DioClient().dio);

  Future<void> exportMAL() async {
    final response = await dio.get('/mal/export');
    final xml = response.data;

    final params = ShareParams(
      files: [
        XFile.fromData(
          utf8.encode(xml),
          mimeType: 'application/xml',
          name: 'MyAnimeList Export',
        ),
      ],
      fileNameOverrides: ['MyAnimeListExport.xml'],
    );

    await SharePlus.instance.share(params);
  }

  Future<String> importMAL() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles();
      if (result == null || result.files.isEmpty) {
        return "No file picked to import from.";
      }
      File file = File(result.files.single.path!);
      String xml = await file.readAsString();
      final res = await dio.post('/mal/import', data: {'malList': xml});
      return res.data["message"];
    } catch (e) {
      rethrow;
    }
  }
}
