import 'package:flutter/material.dart';
import 'package:transaction_account/apis/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void signInUser() {
    authService.signInUser(
      context: context,
      username: usernameController.text,
      password: passwordController.text,
    );
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Column(
          
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("TRANSACTION MANAGEMENT SYSTEM",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            ),
            const SizedBox(height: 120,),
            SizedBox(
              width: 300,
              height: 300,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required!';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field is required!';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signInUser();
                          }
                        },
                        child: const Text('LOGIN',style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Text('Powered By PlutoSol',style: TextStyle(color: Colors.grey[700]),textAlign: TextAlign.center,),
    );
  }
}
