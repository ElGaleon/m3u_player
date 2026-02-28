import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

const allowedExtensions = ['.m3u', '.m3u8'];

final log = Logger('ExampleLogger');

class FileService {
  FileService._();

  static final _instance = FileService._();

  factory FileService() => _instance;

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) log.info('File selected: ${result.files.first.path}');
    return result?.files.first.path;
  }
}
