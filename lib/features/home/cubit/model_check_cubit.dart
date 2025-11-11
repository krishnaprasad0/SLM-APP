import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:external_path/external_path.dart';
import 'package:slm_poc/core/model_list.dart';

part 'model_check_state.dart';

class ModelCheckCubit extends Cubit<ModelCheckState> {
  ModelCheckCubit() : super(ModelCheckInitial());

  Future<void> checkDownloadedModels() async {
    emit(ModelCheckLoading());
    try {
      final downloaded = <String>{};
      final modelSizes = <String, int>{}; // total actual or expected bytes

      final docPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS,
      );

      for (var entry in Models.all.entries) {
        final model = entry.value;
        final modelDir = Directory('$docPath/${model.path}');

        // Expected filenames
        final expectedFiles = model.files
            .map((url) => url.split('/').last)
            .toList();

        int totalBytes = 0;
        bool allFilesExist = true;

        if (await modelDir.exists()) {
          // Calculate existing file sizes
          for (final fileName in expectedFiles) {
            final file = File('${modelDir.path}/$fileName');
            if (await file.exists()) {
              totalBytes += await file.length();
            } else {
              allFilesExist = false;
            }
          }
        } else {
          allFilesExist = false;
        }

        // Mark as downloaded if all exist
        if (allFilesExist) {
          downloaded.add(entry.key);
        }

        // Save total (downloaded or not)
        modelSizes[entry.key] = totalBytes;
      }

      // Always emit ModelDownloaded — even if empty — to have size info
      emit(ModelDownloaded(downloaded, modelSizes));
    } catch (e, st) {
      emit(ModelCheckError("Error checking models: $e"));
      log('❌ Model check failed: $e\n$st');
    }
  }
}
