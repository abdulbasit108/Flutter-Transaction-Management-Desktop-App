import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transaction_account/screens/login.dart';
import 'package:transaction_account/provider/user_provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'Transaction Management System By PlutoSol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Calibri',
      ),
      home: const LoginScreen(),
    );
  }
}






