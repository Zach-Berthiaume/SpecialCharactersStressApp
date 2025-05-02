import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberEmail = false;
  bool _rememberPassword = false;

  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
          if(mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        _toggleForm(true);
        _showSnackbar("Thanks for creating an account!");
      }

      if (_isLogin) {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberEmail) {
          await prefs.setString('saved_email', email);
        } else {
          await prefs.remove('saved_email');
        }
        if (_rememberPassword) {
          await prefs.setString('saved_password', password);
        } else {
          await prefs.remove('saved_password');
        }
      }

    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? "Authentication Error");
    }
  }

  void _toggleForm(bool loginSelected) async {
    setState(() {
      _isLogin = loginSelected;

      if (!loginSelected) {
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _usernameController.clear();
      } else {
        _loadSavedCredentials();
      }
    });
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');

    setState(() {
      if (savedEmail != null) {
        _emailController.text = savedEmail;
        _rememberEmail = true;
      }
      if (savedPassword != null) {
        _passwordController.text = savedPassword;
        _rememberPassword = true;
      }
    });
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message, textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 250),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        if (!_isLogin)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (!_isLogin && (value == null || value.trim().isEmpty)) {
                  return 'Username required';
                }
                return null;
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Email required';
              final emailRegEx = RegExp(r'^[\w-.]+@([\w-]+\.)+\w{2,4}$');
              return emailRegEx.hasMatch(value) ? null : 'Enter a valid email';
            },
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password required';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
        if (_isLogin)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberEmail,
                    onChanged: (value) async {
                      setState(() {
                        _rememberEmail = value ?? false;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      if (!mounted) return;
                      if (_rememberEmail) {
                        await prefs.setString('saved_email', _emailController.text);
                      } else {
                        await prefs.remove('saved_email');
                      }
                    },
                  ),
                  const Text('Remember email'),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Checkbox(
                    value: _rememberPassword,
                    onChanged: (value) async {
                      setState(() {
                        _rememberPassword = value ?? false;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      if (!mounted) return;
                      if (_rememberPassword) {
                        await prefs.setString('saved_password', _passwordController.text);
                      } else {
                        await prefs.remove('saved_password');
                      }
                    },
                  ),
                  const Text('Remember password'),
                ],
              ),
            ],
          ),
        if (!_isLogin)
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Confirm your password';
              if (value != _passwordController.text) return 'Passwords do not match';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Transform.scale(
                      scale: 2.0,
                      child: Image.asset('assets/images/loading.png'),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _toggleForm(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isLogin ? Colors.blue[300] : Colors.blue[100],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                color: _isLogin ? Colors.white : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _toggleForm(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isLogin ? Colors.blue[300] : Colors.blue[100],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: !_isLogin ? Colors.white : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextFields(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Center(
                    child: SizedBox(
                      width: 150,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
