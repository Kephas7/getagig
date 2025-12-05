import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getagig/common/mysnackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  Future<void> loginUser() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      showMySnackBar(context: context, message: e.toString());
    }

    setState(() => loading = false);
  }

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      showMySnackBar(context: context, message: "Enter your email first.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      showMySnackBar(context: context, message: "Password reset email sent!");
    } catch (e) {
      showMySnackBar(context: context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: isLandscape ? 20 : 0),

                    Image.asset(
                      "assets/images/mylogo.png",
                      height: isLandscape ? 90 : 150,
                    ),

                    SizedBox(height: isLandscape ? 12 : 25),

                    Text(
                      "WELCOME",
                      style: TextStyle(
                        fontSize: isLandscape ? 22 : 27,
                        letterSpacing: 3,
                      ),
                    ),

                    SizedBox(height: isLandscape ? 18 : 30),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }

                        final emailRegex = RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                        );

                        if (!emailRegex.hasMatch(value)) {
                          return "Enter a valid email";
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: isLandscape ? 18 : 30),

                    TextFormField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => hidePassword = !hidePassword);
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: resetPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(),
                              ),
                              child: const Text(
                                "Log in",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
