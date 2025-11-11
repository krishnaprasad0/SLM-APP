import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slm_poc/core/model_list.dart';
import 'package:slm_poc/features/home/download_cubit/download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final Dio _dio = Dio();

  DownloadCubit() : super(const DownloadState());

  Future<void> startDownloadFor(Model model) async {
    emit(
      state.copyWith(
        isDownloading: true,
        totalFiles: model.files.length,
        currentFileIndex: 0,
        received: 0,
        total: 0,
        message: '',
        modelName: model.name,
      ),
    );

    try {
      for (var i = 0; i < model.files.length; i++) {
        final url = model.files[i];
        final fileName = url.split('/').last;

        emit(
          state.copyWith(
            currentFileIndex: i,
            message: 'Downloading ${i + 1}/${model.files.length}: $fileName',
          ),
        );

        await _downloadFile(url, fileName, model.path);
      }

      emit(
        state.copyWith(
          isDownloading: false,
          message: '✅ ${model.name} downloaded successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isDownloading: false,
          message: '❌ ${model.name} download failed: $e',
        ),
      );
    }
  }

  Future<void> _downloadFile(
    String url,
    String fileName,
    String modelFolder,
  ) async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) throw Exception('Storage permission not granted');

    final docPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOCUMENTS,
    );

    final modelDir = Directory('$docPath/$modelFolder');
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }

    final filePath = '${modelDir.path}/$fileName';
    print('Saving to: $filePath');

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          // Convert to readable sizes
          final receivedMB = (received / (1024 * 1024)).toStringAsFixed(2);
          final totalMB = (total / (1024 * 1024)).toStringAsFixed(2);

          // Update progress state
          emit(
            state.copyWith(
              received: received,
              total: total,
              message:
                  'Downloading ${state.currentFileIndex + 1}/${state.totalFiles}: $fileName ',
              totalSize: '$receivedMB MB / $totalMB MB',
            ),
          );
        }
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status! < 500,
      ),
    );
  }
}
