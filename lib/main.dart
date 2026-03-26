import 'package:flutter/cupertino.dart';
import 'clearapp.dart';
import 'services/storage_service.dart';
import 'services/alarm_service.dart';
import 'services/photo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  await AlarmService().init();
  await PhotoService.init();
  runApp(const ClearApp());
}

