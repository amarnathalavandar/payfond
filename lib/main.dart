import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:payfond/provider/screenChangeProvider.dart';
import 'package:payfond/views/auth_views/login.dart';
import 'package:payfond/views/main_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( DevicePreview(
    isToolbarVisible: true,
    devices: [
      Devices.ios.iPhone12,
      Devices.ios.iPhone13,
      Devices.android.onePlus8Pro,
      Devices.android.samsungGalaxyA50,
      Devices.android.samsungGalaxyNote20Ultra,
    ],
    builder: (context) => MyApp(), // Wrap your app
  ),);
}
//git change

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScreenChangeProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              fontSize: 18
            ),
            iconTheme: IconThemeData(
              color: Colors.white
            )
          )
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const MainScreen();
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const LoginScreen();
          })
      ));
  }
}
