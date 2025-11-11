import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'model_state.dart';
import 'package:slm_poc/core/model_list.dart';

class ModelCubit extends Cubit<ModelState> {
  ModelCubit() : super(const ModelState());

  Future<void> checkDownloadedModels() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloaded = <String>{};

    for (var entry in Models.all.entries) {
      final modelDir = Directory('${dir.path}/${entry.value.path}');
      if (await modelDir.exists()) {
        downloaded.add(entry.key);
      }
    }

    emit(state.copyWith(downloaded: downloaded));
  }
}
