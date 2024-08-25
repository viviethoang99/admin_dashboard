import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../services/auth_state.dart';
import '../models/login.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPasswordVisible = useState(false);

    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();

    Future<void> onLoginOnPressed() async {
      try {
        final login = Login(
          username: usernameController.text,
          password: passwordController.text,
        );
        await ref.read(currentAuthStateProvider.notifier).login(login);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.blue,
              Colors.red,
            ],
          ),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible.value,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                // Show Password
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: isPasswordVisible.value,
                      onChanged: (value) {
                        isPasswordVisible.value = value!;
                      },
                    ),
                    const Text('Show Password'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onLoginOnPressed,
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
