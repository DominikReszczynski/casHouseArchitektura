import 'package:auto_size_text/auto_size_text.dart';
import 'package:cas_house/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/dasboard_provider.dart';

class LoginSectionMain extends StatefulWidget {
  const LoginSectionMain({super.key});

  @override
  State<LoginSectionMain> createState() => _LoginSectionMainState();
}

class _LoginSectionMainState extends State<LoginSectionMain> {
  late DashboardProvider dashboardProvider;
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dashboardProvider = Provider.of<DashboardProvider>(context, listen: true);
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(builder: (context, loginProvider, child) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AutoSizeText(
                    "LOGIN",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('DODAJ'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
