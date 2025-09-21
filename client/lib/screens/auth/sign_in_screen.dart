import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../../widgets/input_text.dart';
import 'sign_up_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 470),
          child: Card(
            elevation: 15,
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Welcome to Evalora',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  InputText(
                    controller: usernameController,
                    hint: 'Email or username',
                    textStyle: const TextStyle(color: Colors.white),
                    borderColor: Colors.white,
                    fillColor: Colors.black,
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  InputText(
                    controller: passwordController,
                    hint: 'Password',
                    obscure: true,
                    textStyle: const TextStyle(color: Colors.white),
                    borderColor: Colors.white,
                    fillColor: Colors.black,
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                          side: const BorderSide(color: Colors.white, width: 2),
                        ),
                        elevation: 6,
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                              setState(() {
                                loading = true;
                              });
                              try {
                                await ref.read(authProvider.notifier).signIn(
                                      usernameController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                if (ref.read(authProvider) != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const DashboardScreen(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString(),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                letterSpacing: 0.15,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(21),
                        ),
                      ),
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text(
                        "Sign in with Google",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: loading
                          ? null
                          : () async {
                              setState(() {
                                loading = true;
                              });
                              try {
                                await ref.read(authProvider.notifier).signInWithGoogle();
                                if (ref.read(authProvider) != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const DashboardScreen(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                );
                              } finally {
                                setState(() {
                                  loading = false;
                                });
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
