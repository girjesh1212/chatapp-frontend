// ignore_for_file: use_build_context_synchronously

import 'package:chatapp/screens/chat.dart';
import 'package:chatapp/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;

  String? validate(){
    if(_identifierController.text.isEmpty){
      return 'Identifier is required';
    }
    if(_passwordController.text.isEmpty){
      return 'Password is required';
    }
    return null;
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          // Left side
          MediaQuery.of(context).size.width < 680 ? Container() : Expanded(
            child: Center(
              child: Lottie.asset('assets/lottie/login.json', height: MediaQuery.of(context).size.height*0.5),
            ),
          ),

          // Right side
          Expanded(
            child: Container(
              height: double.maxFinite, 
              color: Colors.grey.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Woops! Please login to chat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: TextField(
                      controller: _identifierController,
                      decoration: const InputDecoration(
                        labelText: 'Username or Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        }, icon: Icon( _hidePassword ? Icons.visibility : Icons.visibility_off))
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      try{
                        final validationMessage = validate();
                        if(validationMessage != null) {
                          throw validationMessage;
                        }
                        Map<String, dynamic> res = await context.read<AuthProvider>().login(identifier: _identifierController.text, password: _passwordController.text);
                        if(res['success'] == false){
                          throw res['message'];
                        }
                        Navigator.pushReplacement( context,
                          MaterialPageRoute(builder: (context) => ChatScreen(username: res['username'])),
                        );
                      }catch(e){
                        final snackBar = SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text('$e'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 64),
                  Text('Not having an account?', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black.withAlpha(100))),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shadowColor:Colors.white.withOpacity(0), 
                      backgroundColor: Colors.white.withOpacity(0),
                      disabledBackgroundColor: Colors.white.withOpacity(0),
                      foregroundColor: const Color(0xFF222222),
                    ),
                    onPressed: () {
                      Navigator.push( context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Register Here', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ]
              ),
            ),
          )
        ]
      )
    );
  }
}
