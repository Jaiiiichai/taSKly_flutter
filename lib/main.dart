import 'package:flutter/material.dart';
import 'package:taskly/screens/DashboardScreen.dart';
import 'package:taskly/screens/LoginScreen.dart';
import 'package:taskly/screens/RegisterScreen.dart';
import 'package:provider/provider.dart';
import 'package:taskly/services/TaskProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => TaskProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => Registerscreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
