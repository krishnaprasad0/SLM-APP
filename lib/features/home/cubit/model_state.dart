import 'package:equatable/equatable.dart';
import 'package:slm_poc/core/model_list.dart';

enum ModelStatus { initial, downloading, downloaded, loaded, error }

class ModelState extends Equatable {
  final Map<String, double> progress;
  final Set<String> downloaded;
  final String? activeDownload;
  final String? error;
  final Model? currentModel;

  const ModelState({
    this.progress = const {},
    this.downloaded = const {},
    this.activeDownload,
    this.currentModel,
    this.error,
  });

  ModelState copyWith({
    Map<String, double>? progress,
    Set<String>? downloaded,
    String? activeDownload,
    Model? currentModel,
    String? error,
  }) {
    return ModelState(
      progress: progress ?? this.progress,
      downloaded: downloaded ?? this.downloaded,
      activeDownload: activeDownload ?? this.activeDownload,
      currentModel: currentModel ?? this.currentModel,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    progress,
    downloaded,
    activeDownload,
    currentModel,
    error,
  ];
}
