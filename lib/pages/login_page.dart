import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_button.dart';
import 'package:flutter_application_1/components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  //sign user in method
  void signUserIn() async {
    //loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
      
    Navigator.pop(context);

    //show error message
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(e.message ?? 'An unknown error occurred'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 97, 11),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
            
                //logo
                Icon(
                  Icons.account_circle_rounded,
                  color: Colors.white,
                  size: 100,
                ),
            
                const SizedBox(height: 50),
                
                //email textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'email',
                  obscureText: false,
                  icon: Icons.email,
                ),
            
                const SizedBox(height: 10),
            
                //password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  icon: Icons.lock,
                ),
            
                const SizedBox(height: 10),
            
                //forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(height: 20),
                //sign in button
                MyButton(
                  text: "Sign in",
                  onTap: signUserIn,
                ),
            
                const SizedBox(height: 25),
            
                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
