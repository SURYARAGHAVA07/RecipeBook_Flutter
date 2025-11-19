import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/auth_store.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthStore>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Auth (mock)')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: nameCtr, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: emailCtr, decoration: const InputDecoration(labelText: 'Email')),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      auth.login(emailCtr.text.trim(), nameCtr.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged in')));
                    },
                    child: const Text('Login')),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: () {
                      auth.logout();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
                    },
                    child: const Text('Logout')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
