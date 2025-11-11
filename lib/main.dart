import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slm_poc/features/chat/chat_page.dart';
import 'package:slm_poc/features/chat/cubit/chat_cubit.dart';
import 'package:slm_poc/features/chat/cubit/stt_cubit/stt_cubit.dart';
import 'package:slm_poc/features/home/cubit/model_check_cubit.dart';
import 'package:slm_poc/features/home/download_cubit/download_cubit.dart';
import 'package:slm_poc/features/home/download_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _requestStoragePermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(create: (_) => ChatCubit()),
        BlocProvider<SpeechCubit>(create: (_) => SpeechCubit()..initialize()),
        BlocProvider<ModelCheckCubit>(create: (_) => ModelCheckCubit()),
        BlocProvider<DownloadCubit>(create: (_) => DownloadCubit()),
      ],
      child: MaterialApp(
        title: 'Model Checker App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (_) => const DownloadPage(),
          '/chat': (_) => ChatPage(),
          '/modelList': (_) => const DownloadPage(),
        },
      ),
    );
  }
}

Future<void> _requestStoragePermissions() async {
  try {
    if (await Permission.manageExternalStorage.isGranted) {
      print('✅ Manage external storage already granted.');
      return;
    }
    if (await Permission.manageExternalStorage.isDenied) {
      final result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        print('✅ Manage external storage granted.');
      } else if (result.isPermanentlyDenied) {
        print('⚠️ Manage external storage permanently denied.');
        await openAppSettings();
      } else {
        print('❌ Manage external storage denied.');
      }
      return;
    }

    // Android 10 and below
    final storage = await Permission.storage.status;
    if (storage.isDenied) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        print('✅ Storage permission granted.');
      } else {
        print('❌ Storage permission denied.');
      }
    }
  } on PlatformException catch (e) {
    print('⚠️ Permission request failed: $e');
  }
}
