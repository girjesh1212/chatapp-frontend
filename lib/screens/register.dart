// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/providers/auth.dart';
import 'package:chatapp/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? validate(){
    if(_emailController.text.isEmpty){
      return 'Email is required';
    }
    if(_usernameController.text.isEmpty){
      return 'Username is required';
    }
    if(_passwordController.text.isEmpty){
      return 'Password is required';
    }
    if(_confirmPasswordController.text.isEmpty){
      return 'Confirm Password is required';
    }
    if(!_emailController.text.contains('@')){
      return 'Please enter valid email';
    }
    if(_passwordController.text != _confirmPasswordController.text){
      return 'Passwords do not match';
    }
    return null;
  }
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side
          MediaQuery.of(context).size.width < 680 ? Container() : Expanded(
            child: Center(
              child: Lottie.asset('assets/lottie/register.json', height: MediaQuery.of(context).size.height*0.5),
            ),
          ),
          Expanded(
            child: Container(
              height: double.maxFinite, 
              width: double.maxFinite, 
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Enter Details to register!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        constraints: BoxConstraints(maxWidth: 400)
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        constraints: BoxConstraints(
                          maxWidth: 400
                        )
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: TextField( 
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        constraints: const BoxConstraints(
                          maxWidth: 400
                        ),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        }, icon: Icon( _hidePassword ? Icons.visibility : Icons.visibility_off))
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: const OutlineInputBorder(),
                        constraints: const BoxConstraints(
                          maxWidth: 400
                        ),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            _hideConfirmPassword = !_hideConfirmPassword;
                          });
                        }, icon: Icon( _hideConfirmPassword ? Icons.visibility : Icons.visibility_off))
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      try{
                        final validationMessage = validate();
                        if(validationMessage != null) {
                          throw validationMessage;
                        }
                        Map<String, dynamic> res = await context.read<AuthProvider>().register(username: _usernameController.text, email: _emailController.text, password: _passwordController.text);
                        if(res['success'] == false){
                          throw res['message'];
                        }
                        Navigator.pushAndRemoveUntil<dynamic>(context, MaterialPageRoute<dynamic>(builder: (BuildContext context) => ChatScreen(username: res['username'])),(route) => false);
                      }catch(e){
                        final snackBar = SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text('$e'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }
}