import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:findpix_flutter/app/app.bottomsheets.dart';
import 'package:findpix_flutter/app/app.dialogs.dart';
import 'package:findpix_flutter/app/app.locator.dart';
import 'package:findpix_flutter/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
      // theme: ThemeData(
      //   fontFamily: 'Poppins',
      //   primarySwatch: Colors.red,
      //   // backgroundColor: kBackgroundColor,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
    );
  }
}
