// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:transaction_account/error_handling.dart';
import 'package:transaction_account/screens/menu.dart';
import 'package:transaction_account/provider/user_provider.dart';

class AuthService {
  // sign up user

  // sign in user
  void signInUser({
    required BuildContext context,
    required String username,
    required String password,
  }) async {
    try {
      
      http.Response res = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/users/v1/login/'),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen()),
              (route) => false);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data
}
