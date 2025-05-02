import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/theme.dart';

class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key});

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  String? errorMessage;
  bool _isProcessing = false;
  String? currentEmail;
  bool _isPasswordVisible = false;
  bool _isEmailVisible = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        currentEmail = currentUser.email;
      });
    }
  }

  Future<void> _reauthenticateUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _currentPasswordController.text.isNotEmpty) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: _currentPasswordController.text,
        );
        await currentUser.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message;
        });
        rethrow;
      }
    }
  }

  Future<void> _updateEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      if (_newEmailController.text.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });

        await _reauthenticateUser();

        await currentUser?.verifyBeforeUpdateEmail(_newEmailController.text);

        _showSuccessDialog('Successfully sent verification email.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _updatePassword() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      if (_newPasswordController.text.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });

        await _reauthenticateUser();

        await currentUser?.updatePassword(_newPasswordController.text);

        _showSuccessDialog('Password updated successfully.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(builder: (context, themeModel, child) {
      final isDarkMode = themeModel.isDarkMode;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Account'),
          backgroundColor: isDarkMode ? Colors.blue.shade800 : Colors.lightBlue.shade400,
          elevation: 0,
        ),
        body: Container(
          color: isDarkMode ? Colors.grey.shade900 : Colors.lightBlue.shade50,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (currentEmail != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Current Email: $currentEmail',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  controller: _newEmailController,
                  obscureText: !_isEmailVisible,
                  decoration: InputDecoration(
                    labelText: 'New Email',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blue.shade800),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDarkMode ? Colors.blue.shade800 : Colors.blue.shade400),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isEmailVisible ? Icons.visibility : Icons.visibility_off,
                        color: isDarkMode ? Colors.white70 : Colors.blue.shade800,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEmailVisible = !_isEmailVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blue.shade800),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDarkMode ? Colors.blue.shade800 : Colors.blue.shade400),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: isDarkMode ? Colors.white70 : Colors.blue.shade800,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _updateEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isProcessing ? 'Saving...' : 'Save Email',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isProcessing ? 'Saving...' : 'Save Password',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
