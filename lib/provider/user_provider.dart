import 'package:flutter/material.dart';
import 'package:transaction_account/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: -1, // Provide a default value for id
    token: '',
    username: '',
    email: '',
    isAdmin: false,
  );

  User get user => _user;

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
