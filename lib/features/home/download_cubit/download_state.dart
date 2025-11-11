import 'package:equatable/equatable.dart';

class DownloadState extends Equatable {
  final bool isDownloading;
  final int currentFileIndex;
  final int totalFiles;
  final int received;
  final int total;
  final String message;
  final String modelName;
  final String totalSize;

  const DownloadState({
    this.isDownloading = false,
    this.currentFileIndex = 0,
    this.totalFiles = 0,
    this.received = 0,
    this.total = 0,
    this.message = '',
    this.modelName = '',
    this.totalSize = '',
  });

  double get progress => total == 0 ? 0 : received / total;

  bool get isCompleted => !isDownloading && message == 'Download complete!';

  DownloadState copyWith({
    bool? isDownloading,
    int? currentFileIndex,
    int? totalFiles,
    int? received,
    int? total,
    String? message,
    String? modelName,
    String? totalSize,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      currentFileIndex: currentFileIndex ?? this.currentFileIndex,
      totalFiles: totalFiles ?? this.totalFiles,
      received: received ?? this.received,
      total: total ?? this.total,
      message: message ?? this.message,
      modelName: modelName ?? this.modelName,
      totalSize: totalSize ?? this.totalSize,
    );
  }

  @override
  List<Object?> get props => [
    isDownloading,
    currentFileIndex,
    totalFiles,
    received,
    total,
    message,
  ];
}
