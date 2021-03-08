import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:o/colors.dart';
import 'package:o/models/user.dart';
import 'package:o/models/group.dart';
import 'package:o/profile/data/profile_data.dart';
import 'package:o/profile/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: InitFireBase(),
    theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        brightness: Brightness.dark,
        backgroundColor: AppColors.background),
  ));
}

class InitFireBase extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('failed to initilizing flutter'));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return Profile(profileData: ProfileData(FirebaseFirestore.instance));
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
