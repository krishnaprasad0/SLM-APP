import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slm_poc/core/model_list.dart';
import 'package:slm_poc/features/home/cubit/model_check_cubit.dart';
import 'package:slm_poc/features/home/download_cubit/download_cubit.dart';
import 'package:slm_poc/features/home/download_cubit/download_state.dart';
import 'package:slm_poc/helper/language_helper.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DownloadCubit()),
        BlocProvider(create: (_) => ModelCheckCubit()..checkDownloadedModels()),
      ],
      child: Scaffold(
        floatingActionButton: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/search');
          },
          icon: Icon(Icons.add),
        ),
        appBar: AppBar(
          title: const Text('Model Manager'),
          actions: [
            BlocBuilder<LanguageCubit, String>(
              builder: (context, lang) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      lang == "hi-IN" ? "Hindi" : "English",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settingsPage');
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),

        body: const _DownloadView(),
      ),
    );
  }
}

class _DownloadView extends StatelessWidget {
  const _DownloadView();

  @override
  Widget build(BuildContext context) {
    final models = Models.availableModels;

    return BlocBuilder<ModelCheckCubit, ModelCheckState>(
      builder: (context, checkState) {
        if (checkState is ModelCheckLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final downloadedModels = (checkState is ModelDownloaded)
            ? checkState.downloaded
            : <String>{};

        final modelSizes = (checkState is ModelDownloaded)
            ? checkState.modelSizes
            : <String, int>{};
        return BlocBuilder<DownloadCubit, DownloadState>(
          builder: (context, downloadState) {
            if (downloadState.isDownloading) {
              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '📦 Downloading ${downloadState.modelName}...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: downloadState.progress),
                    const SizedBox(height: 12),
                    Text(
                      'File ${downloadState.currentFileIndex + 1} of ${downloadState.totalFiles}',
                    ),
                    const SizedBox(height: 8),

                    Text("Size of ${downloadState.totalSize}"),
                    Text(
                      '${(downloadState.progress * 100).toStringAsFixed(0)}% complete',
                    ),
                  ],
                ),
              );
            }
            if (downloadState.isCompleted ||
                downloadState.isDownloading == false) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ModelCheckCubit>().checkDownloadedModels();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];

                    final isDownloaded = downloadedModels.contains(model.path);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          model.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          modelSizes[model.path] != null
                              ? '\nSize: ${formatBytes(modelSizes[model.path]!)}'
                              : '',
                          style: const TextStyle(fontSize: 13),
                        ),

                        trailing: isDownloaded
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  // ✅ Navigate to chat page
                                  Navigator.pushNamed(
                                    context,
                                    '/chat',
                                    arguments: model,
                                  );
                                },
                                icon: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Load',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () async {
                                  await context
                                      .read<DownloadCubit>()
                                      .startDownloadFor(model);
                                },
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Download',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              );
            }
            return SizedBox();
          },
        );
      },
    );
  }
}

String formatBytes(int? bytes) {
  if (bytes == null) return '—';
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  final i = (math.log(bytes) / math.log(1024)).floor();
  final size = (bytes / math.pow(1024, i));
  // show two decimal places
  return '${size.toStringAsFixed(2)} ${suffixes[i]}';
}
