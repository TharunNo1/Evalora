import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../../widgets/input_text.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
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
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create an Account',
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
                    controller: nameController,
                    hint: 'Full Name',
                    textStyle: const TextStyle(color: Colors.white),
                    borderColor: Colors.white,
                    fillColor: Colors.black,
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  InputText(
                    controller: emailController,
                    hint: 'Email',
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
                  const SizedBox(height: 16),
                  InputText(
                    controller: confirmPasswordController,
                    hint: 'Confirm Password',
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
                              final name = nameController.text.trim();
                              final email = emailController.text.trim();
                              final password = passwordController.text;
                              final confirmPassword = confirmPasswordController.text;
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter your full name"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (password != confirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Passwords do not match"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all fields"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => loading = true);
                              try {
                                // Register user with email and password
                                await ref.read(authProvider.notifier).signUp(email, password);

                                // Optionally, update displayName on Firebase User
                                var currentUser = ref.read(authProvider).currentUser;
                                if (currentUser != null) {
                                  await currentUser.updateDisplayName(name);
                                  await currentUser.reload();
                                }

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
                                setState(() => loading = false);
                              }
                            },
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
