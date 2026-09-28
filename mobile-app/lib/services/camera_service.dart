import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/app_config.dart';
import '../core/ids.dart';

/// Reason why a photo could not be captured.
enum CameraFailure { permissionDenied, unavailable }

class CameraException implements Exception {
  const CameraException(this.failure);

  final CameraFailure failure;

  @override
  String toString() => 'CameraException(${failure.name})';
}

/// Captures the evidence photos used by the attendance and activity screens.
abstract class CameraService {
  /// Returns the path of the stored photo, or `null` when the worker closes
  /// the camera without taking a picture.
  Future<String?> capturePhoto({bool useFrontCamera = false});
}

/// Production implementation, backed by the `image_picker` plugin.
class ImagePickerCameraService implements CameraService {
  ImagePickerCameraService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<String?> capturePhoto({bool useFrontCamera = false}) async {
    final XFile? shot = await _pickFromCamera(useFrontCamera: useFrontCamera);
    if (shot == null) return null;
    return _persist(shot);
  }

  Future<XFile?> _pickFromCamera({required bool useFrontCamera}) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConfig.evidenceImageMaxWidth.toDouble(),
        imageQuality: AppConfig.evidenceImageQuality,
        preferredCameraDevice:
            useFrontCamera ? CameraDevice.front : CameraDevice.rear,
      );
    } on PlatformException catch (error) {
      final String code = error.code.toLowerCase();
      if (code.contains('denied') || code.contains('permission')) {
        throw const CameraException(CameraFailure.permissionDenied);
      }
      throw const CameraException(CameraFailure.unavailable);
    } on MissingPluginException {
      throw const CameraException(CameraFailure.unavailable);
    }
  }

  /// Copies the capture into the app documents folder.
  ///
  /// The camera plugin writes to a temporary directory that the operating
  /// system may clear while the record is still waiting to be uploaded.
  Future<String> _persist(XFile shot) async {
    final Directory directory = await _evidenceDirectory();
    final String extension =
        p.extension(shot.path).isEmpty ? '.jpg' : p.extension(shot.path);
    final String target = p.join(
      directory.path,
      '${newLocalId('evidence')}$extension',
    );
    final File saved = await File(shot.path).copy(target);
    return saved.path;
  }

  Future<Directory> _evidenceDirectory() async {
    final Directory base = await getApplicationDocumentsDirectory();
    final Directory evidence = Directory(p.join(base.path, 'evidence'));
    if (!await evidence.exists()) {
      await evidence.create(recursive: true);
    }
    return evidence;
  }
}
