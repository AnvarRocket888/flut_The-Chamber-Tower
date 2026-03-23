import 'package:flutter/cupertino.dart';
import 'clearapp.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const ClearApp());
}

