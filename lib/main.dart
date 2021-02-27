import 'package:flutter/material.dart';
import 'package:o/colors.dart';
import 'package:o/profile/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: Profile(),
    theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.dark,
        backgroundColor: AppColors.background),
  ));
}
